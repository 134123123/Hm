import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

// 1. 定义数据模型
class CategoryModel {
  id: number
  name: string
  userId: number
  constructor(id: number, name: string, userId: number) {
    this.id = id; this.name = name; this.userId = userId;
  }
}

// 2. 泛型响应类 (解决 any 报错的关键)
class ResponseResult<T> {
  code: number
  msg: string
  data: T
  constructor(code: number, msg: string, data: T) {
    this.code = code; this.msg = msg; this.data = data;
  }
}

// 3. 请求参数类
class CategoryReq {
  id?: number
  name: string
  userId: number
  constructor(name: string, userId: number, id?: number) {
    this.name = name; this.userId = userId; this.id = id;
  }
}

// 4. 新建/编辑弹窗
@CustomDialog
struct CategoryDialog {
  controller: CustomDialogController
  title: string = '新建分类'
  inputValue: string = ''
  confirmAction: (name: string) => void = () => {}
  @State inputName: string = ''

  aboutToAppear() {
    this.inputName = this.inputValue
  }

  build() {
    Column() {
      Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 16 })

      TextInput({ placeholder: '请输入分类名称', text: this.inputName })
        .backgroundColor('#F5F5F5').height(50).borderRadius(8).width('90%')
        .onChange((val) => this.inputName = val)

      Row() {
        Button('取消').backgroundColor(Color.White).fontColor('#666')
          .onClick(() => this.controller.close())

        Button('确定').backgroundColor('#FFD700').fontColor('#333')
          .onClick(() => {
            if (this.inputName) {
              this.confirmAction(this.inputName)
              this.controller.close()
            } else {
              promptAction.showToast({ message: '名称不能为空' })
            }
          })
      }
      .margin({ top: 20, bottom: 20 }).width('100%').justifyContent(FlexAlign.SpaceEvenly)
    }
    .backgroundColor(Color.White).borderRadius(16).width('80%')
  }
}

@Component
export struct CategoryPage {
  @State categoryList: CategoryModel[] = []
  private baseUrl: string = 'http://192.168.63.229:8080';
  @StorageProp('loginUserId') currentUserId: number = 0;

  // 菜单状态
  @State isMenuShow: boolean = false
  @State selectedCategory: CategoryModel | null = null

  // 弹窗控制器 (懒加载，初始为 null)
  dialogController: CustomDialogController | null = null;

  aboutToAppear() {
    this.loadData();
  }

  // 加载数据
  loadData() {
    if (this.currentUserId === 0) return;
    let httpRequest = http.createHttp();
    httpRequest.request(`${this.baseUrl}/category/list?userId=${this.currentUserId}`, {
      method: http.RequestMethod.GET
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // ✅ 核心修复：使用泛型断言，消除 any
        let res = JSON.parse(data.result.toString()) as ResponseResult<CategoryModel[]>;
        if (res.code === 1) {
          this.categoryList = res.data || [];
        }
      }
    });
  }

  // 打开弹窗 (mode: false=新建, true=编辑)
  openDialog(isEdit: boolean) {
    let title = isEdit ? '编辑分类' : '新建分类';
    let initialValue = (isEdit && this.selectedCategory) ? this.selectedCategory.name : '';

    this.dialogController = new CustomDialogController({
      builder: CategoryDialog({
        title: title,
        inputValue: initialValue,
        confirmAction: (name: string) => {
          if (isEdit && this.selectedCategory) {
            this.updateCategory(this.selectedCategory.id, name);
          } else {
            this.addCategory(name);
          }
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    })
    this.dialogController.open();
  }

  // 添加分类
  addCategory(name: string) {
    let req = new CategoryReq(name, this.currentUserId);
    this.sendRequest(`${this.baseUrl}/category/add`, req, '添加成功');
  }

  // 修改分类
  updateCategory(id: number, name: string) {
    let req = new CategoryReq(name, this.currentUserId, id);
    this.sendRequest(`${this.baseUrl}/category/update`, req, '修改成功');
  }

  // 删除分类
  deleteCategory(id: number) {
    let httpRequest = http.createHttp();
    httpRequest.request(`${this.baseUrl}/category/delete?id=${id}`, {
      method: http.RequestMethod.GET
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        promptAction.showToast({ message: '删除成功' });
        this.loadData();
      }
    });
  }

  // 通用请求发送
  sendRequest(url: string, data: CategoryReq, successMsg: string) {
    let httpRequest = http.createHttp();
    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: data
    }, (err, res) => {
      if (!err && res.responseCode === 200) {
        promptAction.showToast({ message: successMsg });
        this.loadData();
      }
    });
  }

  // 底部菜单 Builder
  @Builder MenuSheet() {
    Column() {
      Text('编辑').width('100%').textAlign(TextAlign.Center).padding(16).fontSize(16).fontColor('#333')
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })
        .onClick(() => {
          this.isMenuShow = false;
          this.openDialog(true); // 打开编辑框
        })

      Text('删除').width('100%').textAlign(TextAlign.Center).padding(16).fontSize(16).fontColor('#FF4D4F')
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })
        .onClick(() => {
          this.isMenuShow = false;
          if (this.selectedCategory) {
            // 可以在这里加个二次确认弹窗
            this.deleteCategory(this.selectedCategory.id);
          }
        })

      Divider().color('#F5F5F5').strokeWidth(8)
      Text('取消').width('100%').textAlign(TextAlign.Center).padding(16).fontSize(16)
        .onClick(() => this.isMenuShow = false)
    }
    .width('100%').backgroundColor(Color.White).borderRadius({ topLeft: 16, topRight: 16 })
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('分类').fontSize(26).fontColor('#333').fontWeight(FontWeight.Bold)
        Blank()
        Image($r('app.media.ic_public_add')).width(28).height(28).fillColor('#333')
          .onClick(() => {
            this.selectedCategory = null;
            this.openDialog(false); // 新建模式
          })
      }
      .width('100%').height(64).backgroundColor(Color.White).padding({ left: 24, right: 24 })
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.03)', offsetY: 2 })

      // 列表内容
      if (this.categoryList.length === 0) {
        Column() {
          Image($r('app.media.ic_public_folder')).width(60).height(60).fillColor('#DDD')
          Text('暂无分类').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.categoryList, (item: CategoryModel) => {
            ListItem() {
              Row() {
                Image($r('app.media.ic_public_folder_filled')).width(24).height(24).fillColor('#FFD700').margin({ right: 16 })
                Text(item.name).fontSize(17).fontColor('#333').fontWeight(FontWeight.Medium)
                Blank()
                Image($r('app.media.ic_public_arrow_right')).width(16).height(16).fillColor('#CCC')
              }
              .width('100%').padding(18).backgroundColor(Color.White).borderRadius(16)
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.03)', offsetY: 2 })
            }
            .onClick(() => {
              // 🔥 点击跳转到分类详情页
              router.pushUrl({
                url: 'pages/CategoryNoteListPage',
                params: { categoryId: item.id, categoryName: item.name }
              })
            })
            // 🔥 长按弹出菜单
            .gesture(
              LongPressGesture().onAction(() => {
                this.selectedCategory = item;
                this.isMenuShow = true;
              })
            )
          })
        }
        .width('92%').layoutWeight(1).margin({ top: 16 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
    .bindSheet($$this.isMenuShow, this.MenuSheet(), { height: SheetSize.FIT_CONTENT, dragBar: false })
  }
}