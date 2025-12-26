import http from '@ohos.net.http';
import router from '@ohos.router';

// 复用之前的 NoteModel
class NoteModel {
  id: number
  title: string
  content: string
  createTime: string
  isLocked: boolean
  isEncrypted: number

  constructor(id: number, title: string, content: string, createTime: string, isLocked: boolean, isEncrypted: number) {
    this.id = id; this.title = title; this.content = content;
    this.createTime = createTime; this.isLocked = isLocked; this.isEncrypted = isEncrypted;
  }
}

class ResponseResult<T> {
  code: number; msg: string; data: T;
  constructor(code: number, msg: string, data: T) { this.code = code; this.msg = msg; this.data = data; }
}

@Component
export struct HistoryPage {
  @State timelineList: NoteModel[] = []
  // ⚠️ 改成你的 IP
  private baseUrl: string = 'http://192.168.63.229:8080';
  @StorageProp('loginUserId') currentUserId: number = 0;

  aboutToAppear() {
    this.loadData();
  }

  onPageShow() {
    this.loadData();
  }

  loadData() {
    if (this.currentUserId === 0) return;
    let httpRequest = http.createHttp();
    // 复用笔记列表接口，按时间倒序
    httpRequest.request(`${this.baseUrl}/note/list?userId=${this.currentUserId}`, {
      method: http.RequestMethod.GET
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<NoteModel[]>;
        if (res.code === 1) {
          this.timelineList = res.data || [];
        }
      }
    });
  }

  build() {
    Column() {
      // 1. 标题栏
      Row() {
        Text('古今 · 时光').fontSize(24).fontColor('#333').fontWeight(FontWeight.Bold)
      }
      .width('100%').height(64).backgroundColor(Color.White)
      .padding({ left: 24 })
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.03)', offsetY: 2 })
      .zIndex(1)

      // 2. 时间轴列表
      if (this.timelineList.length === 0) {
        Column() {
          Image($r('app.media.ic_public_time')).width(60).height(60).fillColor('#DDD')
          Text('暂无时光记录').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.timelineList, (item: NoteModel, index: number) => {
            ListItem() {
              Row({ space: 0 }) {
                // 左侧：时间轴部分
                Column() {
                  // 上半截线
                  Line().width(2).height(20).backgroundColor(index === 0 ? Color.Transparent : '#E0E0E0')
                  // 圆点
                  Circle({ width: 10, height: 10 }).fill(item.isEncrypted === 1 ? '#CCC' : '#FFD700')
                  // 下半截线 (撑满剩余高度)
                  Line().width(2).layoutWeight(1).backgroundColor('#E0E0E0')
                }
                .width(40).alignItems(HorizontalAlign.Center)
                // 确保高度撑满
                .height('100%')

                // 右侧：内容卡片
                Column() {
                  // 日期显示
                  Text((item.createTime || '').substring(0, 10)) // 只显示 YYYY-MM-DD
                    .fontSize(14).fontColor('#999').margin({ bottom: 4 })

                  // 卡片本体
                  Column() {
                    Row() {
                      Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
                      Blank()
                      if (item.isEncrypted === 1) {
                        Image($r('app.media.ic_public_lock')).width(14).height(14).fillColor('#999')
                      }
                    }.width('100%').margin({ bottom: 8 })

                    Text((item.content || '').replace('\n', ' '))
                      .fontSize(14).fontColor('#666')
                      .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .borderRadius(12)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.03)', offsetY: 2 })
                  .onClick(() => {
                    // 点击也可以跳转去编辑，或者只读
                    if (item.isEncrypted !== 1) {
                      router.pushUrl({
                        url: 'pages/NoteEditPage',
                        params: { noteId: item.id, title: item.title, content: item.content, isLocked: item.isEncrypted }
                      })
                    }
                  })
                }
                .layoutWeight(1)
                .padding({ bottom: 20, right: 20 }) // 卡片之间的间距
              }
              .alignItems(VerticalAlign.Top) // 顶部对齐非常重要
            }
          })
        }
        .width('100%').layoutWeight(1).padding({ top: 20 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }
}