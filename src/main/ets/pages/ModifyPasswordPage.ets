// src/main/ets/pages/ModifyPasswordPage.ets
import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// ✅ 1. 定义请求参数结构 (防止 postData 报错)
class UpdatePwdData {
  id: number
  oldPwd: string
  newPwd: string

  constructor(id: number, oldPwd: string, newPwd: string) {
    this.id = id
    this.oldPwd = oldPwd
    this.newPwd = newPwd
  }
}

// ✅ 2. 定义返回结果结构 (防止 res.code 报错)
class ResponseResult {
  code: number
  msg: string
  data: string

  constructor(code: number, msg: string, data: string) {
    this.code = code
    this.msg = msg
    this.data = data
  }
}

@Entry
@Component
struct ModifyPasswordPage {
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''

  // 获取当前登录用户ID
  @StorageProp('loginUserId') currentUserId: number = 0;

  // ⚠️ 确保 IP 是新的
  private baseUrl: string = 'http://192.168.63.229:8080';

  updatePassword() {
    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次新密码不一致' });
      return;
    }
    if (this.oldPassword === '' || this.newPassword === '') {
      promptAction.showToast({ message: '密码不能为空' });
      return;
    }

    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/user/updatePwd`;

    // ✅ 使用类创建对象
    let postData = new UpdatePwdData(this.currentUserId, this.oldPassword, this.newPassword);

    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: postData
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // ✅ 关键修复：加类型断言 as ResponseResult
        let res = JSON.parse(data.result.toString()) as ResponseResult;

        if (res.code === 1) {
          promptAction.showToast({ message: '修改成功，请重新登录' });
          // 修改成功后退出登录
          setTimeout(() => {
            AppStorage.SetOrCreate('loginUserId', 0);
            router.replaceUrl({ url: 'pages/LoginPage' });
          }, 1000);
        } else {
          promptAction.showToast({ message: res.msg || '修改失败' });
        }
      } else {
        promptAction.showToast({ message: '网络错误' });
      }
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_public_arrow_left')).width(24).height(24).fillColor('#333')
          .onClick(() => router.back())
        Text('修改密码').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }
      .width('100%').height(56).padding({ left: 16 })

      Column({ space: 15 }) {
        TextInput({ placeholder: '旧密码', text: this.oldPassword }).type(InputType.Password)
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange(val => this.oldPassword = val)

        TextInput({ placeholder: '新密码', text: this.newPassword }).type(InputType.Password)
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange(val => this.newPassword = val)

        TextInput({ placeholder: '确认新密码', text: this.confirmPassword }).type(InputType.Password)
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange(val => this.confirmPassword = val)

        Button('确认修改').width('100%').height(50).backgroundColor('#5B8FF9')
          .margin({ top: 20 })
          .onClick(() => this.updatePassword())
      }
      .padding(20)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}