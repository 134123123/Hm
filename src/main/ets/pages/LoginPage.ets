import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State pass: string = ''

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width(24).height(24).fillColor(Color.White)
          .onClick(() => {
            // 如果需要返回逻辑可在此添加
          })
        Text('登录')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#5B8FF9')
      .padding({ left: 16 })

      Column() {
        // 账号输入
        Row() {
          Image($r('app.media.ic_public_input_user'))
            .width(24).height(24)
            .margin({ right: 12 })
          TextInput({ placeholder: '请输入您的账号', text: this.account })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => { this.account = value })
        }
        .height(60)
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        .width('100%')

        // 密码输入
        Row() {
          Image($r('app.media.ic_public_lock'))
            .width(24).height(24)
            .margin({ right: 12 })
          TextInput({ placeholder: '请输入您的密码', text: this.pass })
            .type(InputType.Password)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => { this.pass = value })
        }
        .height(60)
        .border({ width: { bottom: 1 }, color: '#EEEEEE' })
        .width('100%')
        .margin({ top: 10 })

        // 登录按钮
        Button('登录', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor('#8EA0E6')
          .width('100%')
          .height(50)
          .margin({ top: 40 })
          .onClick(() => {
            // 登录成功跳转到首页
            router.replaceUrl({ url: 'pages/Index' })
          })

        // 底部文字
        Row() {
          Text('还没有账号？ ').fontColor('#999').fontSize(14)
          Text('立即注册').fontColor('#5B8FF9').fontSize(14)
        }
        .margin({ top: 20 })

      }
      .padding(30)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 20, topRight: 20 })
      .layoutWeight(1)
      .width('100%')

    }
    .height('100%')
    .backgroundColor('#5B8FF9')
  }
}