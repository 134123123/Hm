// src/main/ets/pages/tabs/MinePage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Component
export struct MinePage {
  build() {
    Column() {
      // ===========================
      // 1. 顶部蓝色区域 (用户信息)
      // ===========================
      Column() {
        // 标题栏 (为了还原设计稿，保留了布局，但隐藏了返回箭头)
        Row() {
          Image($r('app.media.ic_public_arrow_left'))
            .width(24).height(24).opacity(0) // 隐藏占位
          Text('我的')
            .fontSize(18).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
          Image($r('app.media.ic_public_arrow_left'))
            .width(24).height(24).opacity(0) // 隐藏占位
        }
        .height(50).width('100%').padding({ left: 16, right: 16 })

        // 用户头像与昵称
        Row() {
          // 头像
          Image($r('app.media.ic_public_input_user'))
            .width(60).height(60)
            .fillColor(Color.White)
            .backgroundColor('#8EA0E6') // 浅蓝底色
            .borderRadius(30)
            .padding(10)

          // 文本信息
          Column() {
            Text('15005188263')
              .fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold)
            Text('普通用户')
              .fontSize(14).fontColor('#E0E0E0').margin({ top: 5 })
          }
          .margin({ left: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 24, bottom: 30, top: 10 })
      }
      .width('100%')
      .backgroundColor('#5B8FF9') // 整体蓝色背景

      // ===========================
      // 2. 功能菜单列表
      // ===========================
      Column() {
        // (1) 记账本 -> 跳转到 AccountPage
        this.SettingItem('记账本', $r('app.media.icon_list_blue'), () => {
          router.pushUrl({ url: 'pages/AccountPage' })
        })

        // (2) 我的分类 -> 提示用户
        this.SettingItem('我的分类', $r('app.media.ic_public_folder_filled'), () => {
          promptAction.showToast({ message: '请点击底部“分类”页签查看' })
        })

        // (3) 修改密码 -> 跳转到 ModifyPasswordPage
        this.SettingItem('修改密码', $r('app.media.ic_public_lock'), () => {
          router.pushUrl({ url: 'pages/ModifyPasswordPage' })
        })

        // (4) 关于 -> 提示版本号
        this.SettingItem('关于', $r('app.media.ic_public_more'), () => {
          promptAction.showToast({ message: '当前版本 v1.0.0' })
        })

        // (5) 退出登录按钮
        Button('退出登录')
          .width('90%')
          .height(44)
          .margin({ top: 40 })
          .backgroundColor('#FF4D4F') // 红色警示色
          .onClick(() => {
            // 清除路由栈并跳转回登录页，防止用户按返回键回来
            router.clear();
            router.replaceUrl({ url: 'pages/LoginPage' });
          })
      }
      .margin({ top: 10 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5') // 页面整体灰底
  }

  // 封装的列表项组件
  @Builder SettingItem(title: string, icon: Resource, callback?: () => void) {
    Row() {
      // 左侧图标
      Image(icon).width(24).height(24).margin({ right: 16 })
      // 中间文字
      Text(title).fontSize(16).layoutWeight(1)
      // 右侧箭头
      Image($r('app.media.ic_public_arrow_right')).width(16).height(16).fillColor('#CCC')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' }) // 底部细分割线
    .onClick(() => {
      if (callback) callback()
    })
  }
}