// src/main/ets/pages/AccountPage.ets
import router from '@ohos.router';
import http from '@ohos.net.http';
// 1. ✅ 修复路径：使用 ../ 找到 model 文件夹
import { AccountModel } from '../model/AccountModel';

// ==========================================
// 定义严格的数据结构 (消除 Property 'xxx' has no initializer 报错)
// ==========================================

// 后端返回的统一结构
class ResponseResult<T> {
  code: number
  msg: string
  data: T

  // ✅ 必须有构造函数进行初始化
  constructor(code: number, msg: string, data: T) {
    this.code = code
    this.msg = msg
    this.data = data
  }
}

class StatsData {
  totalOut: number = 0
  totalIn: number = 0
}

// 界面显示的“每一行”
class AccountItem {
  id: number
  title: string
  time: string
  amount: string
  type: string
  icon: Resource

  constructor(id: number, title: string, time: string, amount: string, type: string, icon: Resource) {
    this.id = id
    this.title = title
    this.time = time
    this.amount = amount
    this.type = type
    this.icon = icon
  }
}

// 界面显示的“每一天” (分组)
class DayRecord {
  date: string
  items: AccountItem[]

  constructor(date: string, items: AccountItem[]) {
    this.date = date
    this.items = items
  }
}

@Entry
@Component
struct AccountPage {

  private baseUrl: string = 'http://192.168.63.229:8080';
  private currentUserId: number = 1;

  @State currentMonth: string = '2023年12月'
  @State totalOut: string = '0.00'
  @State totalIn: string = '0.00'

  // 最终给 UI 渲染的数据数组
  @State records: DayRecord[] = []

  onPageShow() {
    this.loadStats(); // 加载头部统计
    this.loadList();  // 加载列表
  }

  // 🔥 1. 加载头部统计 (总收入/总支出)
  loadStats() {
    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/account/stats?userId=${this.currentUserId}`;

    httpRequest.request(url, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // ✅ 修复：使用 ResponseResult<StatsData> 替代 any
        let res = JSON.parse(data.result.toString()) as ResponseResult<StatsData>;
        if (res.code === 1) {
          // 后端返回的是数字，我们转成字符串保留2位小数
          // 注意：后端可能返回 null，这里做一个安全处理
          let outVal = res.data.totalOut ? res.data.totalOut : 0;
          let inVal = res.data.totalIn ? res.data.totalIn : 0;

          this.totalOut = Number(outVal).toFixed(2);
          this.totalIn = Number(inVal).toFixed(2);
        }
      }
    });
  }

  // 🔥 2. 加载流水列表
  loadList() {
    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/account/list?userId=${this.currentUserId}`;

    httpRequest.request(url, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // ✅ 修复：明确指定泛型为 AccountModel[]
        let res = JSON.parse(data.result.toString()) as ResponseResult<AccountModel[]>;
        if (res.code === 1) {
          // 拿到原始数据，进行分组处理
          this.processData(res.data);
        }
      }
    });
  }

  // 🔥 3. 核心算法：把扁平的列表按日期分组
  processData(list: AccountModel[]) {
    let groupMap = new Map<string, AccountItem[]>();
    let dateOrder: string[] = []; // 记录日期出现的顺序

    // ✅ 修复：给 item 加上明确类型 AccountModel
    list.forEach((item: AccountModel) => {
      // 1. 提取日期 (YYYY-MM-DD) 和 时间 (HH:mm)
      // item.createTime 格式假设为 "2023-12-21 12:00:00"
      let dateStr = item.createTime.split(' ')[0]; // 拿 "2023-12-21"
      let timeStr = "";
      if (item.createTime.split(' ').length > 1) {
        timeStr = item.createTime.split(' ')[1].substring(0, 5); // 拿 "12:00"
      }

      // 2. 转换对象
      let uiItem = new AccountItem(
        item.id,
        item.title,
        `${timeStr} | ${item.remark || '无备注'}`,
        (item.type === 'out' ? '-' : '+') + Number(item.amount).toFixed(2),
        item.type,
        // 根据类型分配默认图标
        item.type === 'out' ? $r('app.media.ic_public_folder_filled') : $r('app.media.ic_public_input_user')
      );

      // 3. 放入 Map
      if (!groupMap.has(dateStr)) {
        groupMap.set(dateStr, []);
        dateOrder.push(dateStr); // 记录新出现的日期
      }
      let group = groupMap.get(dateStr);
      if (group) {
        group.push(uiItem);
      }
    });

    // 4. 组装成 UI 需要的结构
    let finalRecords: DayRecord[] = [];
    // ✅ 修复：给 date 加上明确类型 string
    dateOrder.forEach((date: string) => {
      let items = groupMap.get(date);
      if (items) {
        finalRecords.push(new DayRecord(date, items));
      }
    });

    this.records = finalRecords;
  }

  build() {
    Column() {
      // 1. 顶部蓝色区域
      Column() {
        // 导航栏
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width(24).height(24).fillColor(Color.White)
            .onClick(() => router.back())
          Text('账本').fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold).margin({ left: 16 })
          Blank()
          Image($r('app.media.ic_public_more')).width(24).height(24).fillColor(Color.White)
        }
        .width('100%').height(56).padding({ left: 16, right: 16 })

        // "明细 / 统计" 切换
        Row() {
          Text('明细').fontSize(18).fontColor(Color.White).fontWeight(FontWeight.Bold).margin({ right: 20 })
          Text('统计').fontSize(16).fontColor('#D0D0D0')
        }
        .width('100%').padding({ left: 20, bottom: 10 })

        // 月份和总览
        Row() {
          Row() {
            Text(this.currentMonth).fontSize(16).fontColor(Color.White)
            Image($r('app.media.ic_public_arrow_right')).width(12).height(12).fillColor(Color.White).rotate({ angle: 90 }).margin({ left: 4 })
          }
          .padding({ top: 4, bottom: 4, left: 8, right: 8 })
          .backgroundColor('#40FFFFFF').borderRadius(12)

          Blank()
          Text(`总支出: ¥${this.totalOut}`).fontSize(12).fontColor(Color.White).margin({ right: 10 })
          Text(`总入账: ¥${this.totalIn}`).fontSize(12).fontColor(Color.White)
        }
        .width('100%').padding({ left: 16, right: 16, bottom: 20 })

      }
      .width('100%')
      .backgroundColor('#5B8FF9')

      // 2. 账单列表
      List() {
        ForEach(this.records, (dayRecord: DayRecord) => {
          // 日期头
          ListItem() {
            Row() {
              Text(dayRecord.date).fontSize(14).fontColor('#999')
              Blank()
            }
            .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 4 })
            .backgroundColor('#F5F5F5')
          }

          // 当天的每一笔记录
          ForEach(dayRecord.items, (item: AccountItem) => {
            ListItem() {
              Row() {
                // 图标背景
                Column() {
                  Image(item.icon).width(24).height(24).fillColor(Color.White)
                }
                .width(40).height(40).borderRadius(20).backgroundColor('#8EA0E6')
                .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                .margin({ right: 12 })

                // 信息
                Column() {
                  Text(item.title).fontSize(16).fontColor('#333')
                  Text(item.time).fontSize(12).fontColor('#999').margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // 金额
                Text(item.amount)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(item.type === 'out' ? '#333' : '#E65B5B') // 支出黑色，收入红色
              }
              .width('100%').padding(16).backgroundColor(Color.White)
              .border({ width: { bottom: 1 }, color: '#F0F0F0' })
            }
          })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%').height('100%')
  }
}