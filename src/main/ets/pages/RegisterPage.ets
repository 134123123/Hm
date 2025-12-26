// src/main/ets/pages/RegisterPage.ets
import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 定义注册请求参数结构
class RegisterData {
  username: string
  password: string
  nickname: string

  constructor(username: string, password: string, nickname: string) {
    this.username = username
    this.password = password
    this.nickname = nickname
  }
}

// 定义后端返回结构
class RegisterResponse {
  code: number
  msg: string
  data: string // 注册接口返回通常是字符串 "注册成功"

  constructor(code: number, msg: string, data: string) {
    this.code = code
    this.msg = msg
    this.data = data
  }
}

@Entry
@Component
struct RegisterPage {
  @State username: string = ''
  @State nickname: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''

  // ✅ 必须确保这里也是新 IP
  private baseUrl: string = 'http://192.168.63.229:8080';

  register() {
    // 1. 前端校验
    if (this.username === '' || this.password === '') {
      promptAction.showToast({ message: '账号和密码不能为空' });
      return;
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    // 2. 发送请求
    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/user/register`;

    let postData = new RegisterData(this.username, this.password, this.nickname || '新用户');

    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: postData
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // 解析结果
        let res = JSON.parse(data.result.toString()) as RegisterResponse;

        if (res.code === 1) {
          promptAction.showToast({ message: '注册成功，请登录' });
          // 注册成功后，延迟跳转回登录页
          setTimeout(() => {
            router.back();
          }, 1000);
        } else {
          promptAction.showToast({ message: res.msg || '注册失败' });
        }
      } else {
        promptAction.showToast({ message: '网络请求失败，请检查IP' });
      }
    });
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width(24).height(24).fillColor(Color.Black)
          .onClick(() => router.back())
        Text('注册账号').fontSize(20).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }
      .width('100%').height(56).padding({ left: 16 })

      Column({ space: 20 }) {
        // 输入框组
        TextInput({ placeholder: '请输入账号 (手机号)', text: this.username })
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => this.username = val)

        TextInput({ placeholder: '请输入昵称 (选填)', text: this.nickname })
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => this.nickname = val)

        TextInput({ placeholder: '请输入密码', text: this.password })
          .type(InputType.Password)
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => this.password = val)

        TextInput({ placeholder: '再次确认密码', text: this.confirmPassword })
          .type(InputType.Password)
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => this.confirmPassword = val)

        // 注册按钮
        Button('立即注册')
          .width('100%').height(50).backgroundColor('#5B8FF9')
          .margin({ top: 20 })
          .onClick(() => this.register())
      }
      .padding(20)
    }
    .width('100%').height('100%').backgroundColor(Color.White)
  }
}