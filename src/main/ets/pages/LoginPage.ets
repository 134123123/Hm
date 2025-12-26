// src/main/ets/pages/LoginPage.ets
import router from '@ohos.router';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 定义登录返回的数据结构
class UserData {
  id: number
  username: string
  nickname: string
  avatar: string

  constructor(id: number, username: string, nickname: string, avatar: string) {
    this.id = id
    this.username = username
    this.nickname = nickname
    this.avatar = avatar
  }
}

class LoginResult {
  code: number
  msg: string
  data: UserData

  constructor(code: number, msg: string, data: UserData) {
    this.code = code
    this.msg = msg
    this.data = data
  }
}

// 定义登录请求参数的结构
class LoginPostData {
  username: string
  password: string

  constructor(username: string, password: string) {
    this.username = username
    this.password = password
  }
}

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State password: string = ''

  private baseUrl: string = 'http://192.168.63.229:8080';

  login() {
    promptAction.showToast({ message: '正在尝试连接...' + this.baseUrl });
    if (this.account === '' || this.password === '') {
      promptAction.showToast({ message: '账号或密码不能为空' });
      return;
    }

    let httpRequest = http.createHttp();
    let url = `${this.baseUrl}/user/login`;

    let postData = new LoginPostData(this.account, this.password);

    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: postData
    }, (err, data) => {
      if (!err && data.responseCode === 200) {
        // 解析结果
        let res = JSON.parse(data.result.toString()) as LoginResult;

        if (res.code === 1) {
          promptAction.showToast({ message: '登录成功' });

          AppStorage.SetOrCreate('loginUserId', res.data.id);
          AppStorage.SetOrCreate('loginUserName', res.data.username);
          AppStorage.SetOrCreate('loginNickName', res.data.nickname);

          // 延迟跳转到首页
          setTimeout(() => {
            // 使用 replaceUrl 销毁登录页，防止用户按返回键退回登录页
            router.replaceUrl({ url: 'pages/Index' });
          }, 500);
        } else {
          promptAction.showToast({ message: res.msg || '登录失败' });
        }
      } else {
        promptAction.showToast({ message: '网络错误，请检查IP配置' });
      }
    });
  }

  build() {
    Column() {
      // 顶部背景
      Column() {
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width(24).height(24).fillColor(Color.White)
            .onClick(() => {
              // 退出APP或其他逻辑
            })
          Text('登录').fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold).margin({ left: 16 })
        }
        .width('100%').height(56).padding({ left: 16 })
      }
      .width('100%').height(200).backgroundColor('#5B8FF9')

      // 白色卡片区域
      Column() {
        // 账号输入
        Row() {
          Image($r('app.media.ic_public_input_user')).width(24).height(24).fillColor('#999')
          TextInput({ placeholder: '请输入您的账号', text: this.account })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((val) => this.account = val)
        }
        .height(60).border({ width: { bottom: 1 }, color: '#F0F0F0' }).width('100%')
        .padding({ left: 10, right: 10 })

        // 密码输入
        Row() {
          Image($r('app.media.ic_public_lock')).width(24).height(24).fillColor('#999')
          TextInput({ placeholder: '请输入您的密码', text: this.password })
            .type(InputType.Password)
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((val) => this.password = val)
          Image($r('app.media.ic_public_visible')).width(24).height(24).fillColor('#999')
        }
        .height(60).border({ width: { bottom: 1 }, color: '#F0F0F0' }).width('100%')
        .padding({ left: 10, right: 10 })

        // 登录按钮
        Button('登录', { type: ButtonType.Capsule })
          .width('100%').height(50).backgroundColor('#8EA0E6')
          .margin({ top: 40 })
          .onClick(() => {
            this.login();
          })

        // 注册引导
        Row() {
          Text('还没有账号？').fontColor('#999')
          Text('立即注册')
            .fontColor('#5B8FF9')
            .onClick(() => {
              // ✅ 修复注册跳转
              router.pushUrl({ url: 'pages/RegisterPage' })
            })
        }
        .margin({ top: 20 })

      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(20)
      .margin({ top: -50 }) // 让卡片上移压住蓝色背景
      .shadow({ radius: 10, color: '#20000000', offsetY: 5 })

    }
    .width('100%').height('100%').backgroundColor('#FAFAFA')
  }
}