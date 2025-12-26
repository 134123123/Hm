import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { NoteModel } from '../../model/NoteModel';

// ================= 类型定义区域 =================

class VerifyPwdReq {
  id: number; safePwd: string;
  constructor(id: number, safePwd: string) { this.id = id; this.safePwd = safePwd; }
}

class EncryptReq {
  id: number; isEncrypted: number;
  constructor(id: number, isEncrypted: number) { this.id = id; this.isEncrypted = isEncrypted; }
}

class ResponseResult<T> {
  code: number; msg: string; data: T;
  constructor(code: number, msg: string, data: T) { this.code = code; this.msg = msg; this.data = data; }
}

class MoveCategoryReq {
  noteId: number; categoryId: number;
  constructor(noteId: number, categoryId: number) { this.noteId = noteId; this.categoryId = categoryId; }
}

// 简化的分类模型 (用于选择框)
class SimpleCategory {
  id: number; name: string;
  constructor(id: number, name: string) { this.id = id; this.name = name; }
}

// ================= 组件区域 =================

// 1. 密码弹窗
@CustomDialog
struct PasswordDialog {
  controller: CustomDialogController
  title: string = '请输入保险箱密码'
  confirmAction: (pwd: string) => void = (pwd) => {}
  @State inputPwd: string = ''
  build() {
    Column() {
      Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      TextInput({ placeholder: '请输入密码', text: this.inputPwd }).type(InputType.Password).backgroundColor('#F5F5F5').height(50).borderRadius(8).width('90%').onChange((val) => this.inputPwd = val)
      Row() {
        Button('取消').backgroundColor(Color.White).fontColor('#666').onClick(() => this.controller.close())
        Button('确定').backgroundColor('#5B8FF9').onClick(() => { this.confirmAction(this.inputPwd); this.controller.close() })
      }.margin({ top: 20, bottom: 20 }).width('80%').justifyContent(FlexAlign.SpaceEvenly)
    }.backgroundColor(Color.White).borderRadius(16).width('80%')
  }
}

// 2. 分类选择弹窗
@CustomDialog
struct CategorySelectDialog {
  controller: CustomDialogController
  categoryList: SimpleCategory[] = []
  onSelect: (categoryId: number) => void = () => {}

  build() {
    Column() {
      Text('选择归档分类').fontSize(18).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 16 })

      if (this.categoryList.length === 0) {
        Text('暂无分类，请先去创建').fontColor('#999').margin(20)
      } else {
        List() {
          ForEach(this.categoryList, (item: SimpleCategory) => {
            ListItem() {
              Text(item.name)
                .fontSize(16).fontColor('#333')
                .width('100%').textAlign(TextAlign.Center).padding(16)
            }
            .onClick(() => {
              this.onSelect(item.id)
              this.controller.close()
            })
          })
        }
        .divider({ strokeWidth: 1, color: '#F0F0F0' }) // 分割线
        .height(200).width('100%')
      }

      Button('取消').backgroundColor(Color.Transparent).fontColor('#666')
        .onClick(()=>this.controller.close()).margin({bottom: 16, top: 10})
    }
    .backgroundColor(Color.White).borderRadius(16).width('80%')
  }
}

@Component
export struct NoteListPage {
  @State allNotes: NoteModel[] = []
  @State searchText: string = ''
  private baseUrl: string = 'http://192.168.63.229:8080';

  // 🔥🔥🔥 修复点 1：加上 @Watch 监听器，一旦 ID 有值了自动刷新
  @StorageProp('loginUserId') @Watch('onUserChange') currentUserId: number = 0;

  @State isMenuShow: boolean = false
  @State selectedNote: NoteModel | null = null
  @State isSideBarOpen: boolean = false
  @State currentMenu: string = 'all'

  dialogController: CustomDialogController | null = null;
  categoryDialogController: CustomDialogController | null = null;

  @State categoryList: SimpleCategory[] = []

  // 🔥🔥🔥 修复点 2：监听 ID 变化的方法
  onUserChange() {
    console.info('用户ID已就绪，自动刷新列表:', this.currentUserId);
    this.loadNotes();
  }

  onPageShow() {
    // 页面每次显示都尝试刷新（解决编辑/锁屏后返回不刷新的问题）
    this.loadNotes();
  }

  loadNotes() {
    if (this.currentUserId === 0) {
      console.warn('用户ID为0，等待加载...');
      return;
    }
    if (this.currentMenu === 'trash') { this.allNotes = []; return; }

    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/note/list?userId=${this.currentUserId}`;

    httpRequest.request(url, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<NoteModel[]>;
        if (res.code === 1) {
          this.allNotes = res.data || [];
        }
      }
    });
  }

  loadCategoriesAndShowDialog() {
    let httpRequest = http.createHttp();
    httpRequest.request(`${this.baseUrl}/category/list?userId=${this.currentUserId}`, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<SimpleCategory[]>;
        if (res.code === 1) {
          this.categoryList = res.data || [];
          this.openCategoryDialog();
        }
      } else {
        promptAction.showToast({ message: '获取分类失败' });
      }
    });
  }

  openCategoryDialog() {
    this.categoryDialogController = new CustomDialogController({
      builder: CategorySelectDialog({
        categoryList: this.categoryList,
        onSelect: (catId: number) => {
          this.moveNoteToCategory(catId);
        }
      }),
      autoCancel: true, alignment: DialogAlignment.Center
    })
    this.categoryDialogController.open();
  }

  moveNoteToCategory(categoryId: number) {
    if (!this.selectedNote) return;
    let httpRequest = http.createHttp();
    let req = new MoveCategoryReq(this.selectedNote.id, categoryId);

    httpRequest.request(`${this.baseUrl}/note/moveCategory`, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: req
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        promptAction.showToast({ message: '归档成功' });
        this.loadNotes();
      }
    });
  }

  onNoteClick(item: NoteModel) {
    if (item.isEncrypted === 1) {
      this.selectedNote = item;
      if (this.dialogController === null) {
        this.dialogController = new CustomDialogController({ builder: PasswordDialog({ confirmAction: (pwd: string) => { this.checkPasswordAndOpen(pwd) } }), autoCancel: true, alignment: DialogAlignment.Center })
      }
      this.dialogController.open();
    } else { this.jumpToEdit(item); }
  }
  checkPasswordAndOpen(pwd: string) {
    let httpRequest = http.createHttp(); let postData = new VerifyPwdReq(this.currentUserId, pwd);
    httpRequest.request(`${this.baseUrl}/user/verifySafePwd`, { method: http.RequestMethod.POST, header: { 'Content-Type': 'application/json' }, extraData: postData }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<string>;
        if (res.code === 1) { if (this.selectedNote) this.jumpToEdit(this.selectedNote); } else { promptAction.showToast({ message: '密码错误' }); }
      }
    });
  }
  jumpToEdit(item: NoteModel) { router.pushUrl({ url: 'pages/NoteEditPage', params: { noteId: item.id, title: item.title, content: item.content, isLocked: item.isEncrypted } }) }
  toggleEncryption(note: NoteModel) {
    let newState = (note.isEncrypted === 1) ? 0 : 1; let httpRequest = http.createHttp(); let postData = new EncryptReq(note.id, newState);
    httpRequest.request(`${this.baseUrl}/note/encrypt`, { method: http.RequestMethod.POST, header: { 'Content-Type': 'application/json' }, extraData: postData }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<string>;
        if (res.code === 1) {
          promptAction.showToast({ message: newState === 1 ? '已加密' : '已解密' });
          // 操作成功后刷新列表
          this.loadNotes();
        }
      }
    });
  }
  deleteNote(id: number) {
    let httpRequest = http.createHttp();
    httpRequest.request(`${this.baseUrl}/note/delete?id=${id}`, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) { promptAction.showToast({ message: '删除成功' }); this.loadNotes(); }
    });
  }

  @Builder MenuSheet() {
    Column() {
      this.MenuItem('置顶', () => promptAction.showToast({ message: '置顶功能开发中' }))
      this.MenuItem('删除', () => { if (this.selectedNote) this.deleteNote(this.selectedNote.id); this.isMenuShow = false; })
      this.MenuItem(this.selectedNote?.isEncrypted === 1 ? '解密' : '加密', () => { if (this.selectedNote) this.toggleEncryption(this.selectedNote); this.isMenuShow = false; })

      this.MenuItem('分类', () => {
        this.isMenuShow = false;
        this.loadCategoriesAndShowDialog();
      })

      this.MenuItem('复制', () => promptAction.showToast({ message: '已复制' }))
      Divider().color('#F5F5F5').strokeWidth(8)
      Text('取消').width('100%').textAlign(TextAlign.Center).padding(16).fontSize(16).onClick(() => this.isMenuShow = false)
    }.width('100%').backgroundColor(Color.White).borderRadius({ topLeft: 16, topRight: 16 })
  }
  @Builder MenuItem(text: string, callback: () => void) {
    Text(text).width('100%').textAlign(TextAlign.Center).padding(16).fontSize(16).fontColor('#333').border({ width: { bottom: 1 }, color: '#F0F0F0' }).onClick(callback)
  }

  @Builder SideBarView() {
    Column() {
      Column() {
        Text('我的笔记').fontSize(24).fontColor(Color.White).fontWeight(FontWeight.Bold).margin({bottom: 8})
        Text('记录生活点滴').fontSize(14).fontColor('rgba(255,255,255,0.8)')
      }
      .width('100%').height(160)
      .linearGradient({ angle: 135, colors: [[0x6A85B6, 0.0], [0xBAC8E0, 1.0]] })
      .padding({ left: 24, bottom: 24 })
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)

      Column() {
        this.SideBarItem('全部笔记', 'all', $r('app.media.ic_public_view_list_filled'), '#4A90E2')
        this.SideBarItem('回收站', 'trash', $r('app.media.ic_public_folder_filled'), '#999999')
      }
      .width('100%').padding({ top: 16, left: 8, right: 8 })
    }
    .width('80%').height('100%').backgroundColor(Color.White)
    .shadow({ radius: 10, color: 'rgba(0,0,0,0.2)', offsetX: 5, offsetY: 0 })
  }

  @Builder SideBarItem(title: string, key: string, icon: Resource, iconColor: string) {
    Row() {
      Image(icon).width(24).height(24).fillColor(this.currentMenu === key ? '#4A90E2' : iconColor)
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 16 }).fontColor(this.currentMenu === key ? '#4A90E2' : '#333')
    }
    .width('100%').height(56).padding({ left: 16 })
    .backgroundColor(this.currentMenu === key ? '#E6F0FF' : Color.Transparent).borderRadius(8)
    .onClick(() => {
      this.currentMenu = key;
      animateTo({ duration: 250 }, () => { this.isSideBarOpen = false });
      if (key === 'trash') { this.allNotes = []; } else { this.loadNotes(); }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          Row() {
            Image($r('app.media.ic_public_view_list')).width(24).height(24).fillColor('#333').onClick(() => { animateTo({ duration: 300, curve: Curve.EaseOut }, () => { this.isSideBarOpen = true }) })
            Text(this.currentMenu === 'trash' ? '回收站' : '笔记').fontSize(20).fontColor('#333').fontWeight(FontWeight.Bold).layoutWeight(1).margin({ left: 16 })
            Image($r('app.media.ic_public_search')).width(24).height(24).fillColor('#333').margin({ right: 16 }).onClick(() => { promptAction.showToast({ message: '点击了搜索' }) })
          }.height(56).width('100%').backgroundColor(Color.White).padding({ left: 16, right: 4 }).shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

          if (this.allNotes.length === 0) {
            Column() { Image($r('app.media.ic_public_folder')).width(60).height(60).fillColor('#DDD'); Text('暂无内容').fontSize(14).fontColor('#999').margin({ top: 10 }) }.width('100%').height('60%').justifyContent(FlexAlign.Center)
          } else {
            List({ space: 12 }) {
              ForEach(this.allNotes.filter(item => item.title.includes(this.searchText)), (item: NoteModel) => {
                ListItem() {
                  Column({ space: 8 }) {
                    Row() {
                      Text(item.title).fontSize(17).fontWeight(FontWeight.Medium).fontColor('#333').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                      Blank()
                      if (item.isEncrypted === 1) { Image($r('app.media.ic_public_lock')).width(16).height(16).fillColor('#999').margin({ right: 8 }) }
                    }.width('100%')
                    Row() {
                      Text((item.createTime || '').length > 10 ? item.createTime.substring(5, 16) : '刚刚').fontSize(13).fontColor('#999')
                      Blank()
                      Text((item.content || '').replace('\n', ' ').substring(0, 15) + '...').fontSize(13).fontColor('#aaa').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    }.width('100%')
                  }
                  .padding(16).backgroundColor(Color.White).borderRadius(12).shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 }).width('100%')
                }
                .onClick(() => this.onNoteClick(item))
                .gesture(LongPressGesture().onAction(() => { this.selectedNote = item; this.isMenuShow = true; }))
              })
            }.width('94%').layoutWeight(1).margin({ top: 12 })
          }
        }.width('100%').height('100%').backgroundColor('#F8F9FA')

        if (this.currentMenu === 'all') {
          Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_edit')).width(28).height(28).fillColor(Color.White) }
          .width(64).height(64).backgroundColor('#FFD700').margin({ right: 24, bottom: 36 }).shadow({ radius: 8, color: 'rgba(255, 215, 0, 0.4)', offsetY: 4 })
          .onClick(()=>router.pushUrl({url:'pages/NoteEditPage'}))
        }
      }
      .width('100%').height('100%')
      .bindSheet($$this.isMenuShow, this.MenuSheet(), { height: SheetSize.FIT_CONTENT, dragBar: false })

      if (this.isSideBarOpen) {
        Rect().width('100%').height('100%').fill(Color.Black).opacity(0.4).onClick(() => { animateTo({ duration: 300 }, () => { this.isSideBarOpen = false }) }).transition(TransitionEffect.OPACITY).zIndex(998)
      }
      if (this.isSideBarOpen) {
        Column() { this.SideBarView() }.transition(TransitionEffect.move(TransitionEdge.START)).zIndex(999)
      }
    }
    .width('100%').height('100%')
  }
}