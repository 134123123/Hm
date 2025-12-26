import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 请求参数类
class NoteReq {
  id: number; title: string; content: string; userId: number; isEncrypted: number;
  constructor(id: number, title: string, content: string, userId: number, isEncrypted: number) {
    this.id = id; this.title = title; this.content = content; this.userId = userId; this.isEncrypted = isEncrypted;
  }
}
class ResponseResult { code: number; msg: string; constructor(code: number, msg: string) { this.code = code; this.msg = msg; } }

@Entry
@Component
struct NoteEditPage {
  @State noteId: number = 0
  @State title: string = ''
  @State content: string = ''
  @State isLocked: boolean = false
  private baseUrl: string = 'http://192.168.63.229:8080'; // ⚠️ 确保IP正确
  @StorageProp('loginUserId') currentUserId: number = 0;

  aboutToAppear() {
    let params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params.noteId) this.noteId = params.noteId as number;
      if (params.title) this.title = params.title as string;
      if (params.content) this.content = params.content as string;
      if (params.isLocked) this.isLocked = (params.isLocked as number) === 1;
    }
  }

  saveNote() {
    if (this.title === '') { promptAction.showToast({ message: '标题不能为空' }); return; }
    let httpRequest = http.createHttp();
    let encryptStatus = this.isLocked ? 1 : 0;
    let postData = new NoteReq(this.noteId, this.title, this.content, this.currentUserId, encryptStatus);
    let apiUrl = this.noteId === 0 ? `${this.baseUrl}/note/add` : `${this.baseUrl}/note/update`;
    httpRequest.request(apiUrl, { method: http.RequestMethod.POST, header: { 'Content-Type': 'application/json' }, extraData: postData }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult;
        if (res.code === 1) { promptAction.showToast({ message: '保存成功' }); setTimeout(() => router.back(), 800); } else { promptAction.showToast({ message: '保存失败' }); }
      } else { promptAction.showToast({ message: '网络错误' }); }
    });
  }

  build() {
    Column() {
      // 1. 顶部导航栏 (白底灰字风格)
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width(24).height(24).fillColor('#333') // 灰色图标
          .onClick(() => router.back())

        Blank() // 用 Blank 撑开，不用 Text 标题，更极简

        // 私密开关 (放在标题栏右侧)
        if (this.isLocked) {
          Image($r('app.media.ic_public_lock')).width(20).height(20).fillColor('#FFD700').margin({right: 16})
            .onClick(()=> this.isLocked = false)
        } else {
          Image($r('app.media.ic_public_unlock')).width(20).height(20).fillColor('#aaa').margin({right: 16})
            .onClick(()=> this.isLocked = true)
        }

        // 保存按钮 (灰色对号)
        Image($r('app.media.ic_public_ok_filled'))
          .width(24).height(24).fillColor('#333') // 灰色图标
          .onClick(() => this.saveNote())
      }
      .width('100%').height(56).backgroundColor(Color.White).padding({ left: 16, right: 16 })
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.05)', offsetY: 1 })

      // 2. 编辑区域 (极简风格，无边框)
      Column() {
        // 标题输入 (大号字体，无背景)
        TextInput({ placeholder: '标题', text: this.title })
          .fontSize(24).fontWeight(FontWeight.Bold)
          .backgroundColor(Color.Transparent) // 透明背景
          .padding({ left: 0, top: 16, bottom: 16 }) // 调整内边距
          .onChange((val) => this.title = val)

        // 内容输入 (撑满剩余空间，无背景)
        TextArea({ placeholder: '记点什么...', text: this.content })
          .layoutWeight(1) // 撑满剩余高度
          .backgroundColor(Color.Transparent) // 透明背景
          .fontSize(16).fontColor('#333')
          .padding({ left: 0, top: 0 })
          .align(Alignment.TopStart) // 内容顶对齐
          .onChange((val) => this.content = val)
      }
      .width('100%').layoutWeight(1) // 撑满剩余空间
      .padding({ left: 20, right: 20, bottom: 20 }) // 整体内边距
      .backgroundColor(Color.White) // 白底
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}