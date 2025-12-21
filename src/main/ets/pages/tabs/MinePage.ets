@Component
export struct MinePage {
  build() {
    Column() {
      // 蓝色头部背景
      Column() {
        Row() {
          Image($r('app.media.ic_public_arrow_left')).width(24).height(24).fillColor(Color.White)
          Text('我的').fontSize(18).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
          Image($r('app.media.ic_public_arrow_left')).width(24).height(24).opacity(0)
        }
        .height(50)
        .width('100%')
        .padding({ left: 16, right: 16 })

        // 用户头像区域
        Row() {
          Image($r('app.media.ic_public_input_user')) // 暂用此图标做头像
            .width(60).height(60)
            .fillColor(Color.White)
            .backgroundColor('#8EA0E6')
            .borderRadius(30)
            .padding(10)

          Column() {
            Text('15005188263').fontSize(20).fontColor(Color.White).fontWeight(FontWeight.Bold)
            Text('普通用户').fontSize(14).fontColor('#E0E0E0').margin({ top: 5 })
          }
          .margin({ left: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 24, bottom: 30, top: 10 })
      }
      .width('100%')
      .backgroundColor('#5B8FF9')

      // 功能列表
      Column() {
        // 记账本入口
        this.SettingItem('记账本', $r('app.media.icon_list_blue')) // 暂用列表图标
        this.SettingItem('我的分类', $r('app.media.ic_public_folder_filled'))
        this.SettingItem('修改密码', $r('app.media.ic_public_lock'))
        this.SettingItem('关于', $r('app.media.ic_public_more'))
      }
      .margin({ top: 10 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder SettingItem(title: string, icon: Resource) {
    Row() {
      Image(icon).width(24).height(24).margin({ right: 16 })
      Text(title).fontSize(16).layoutWeight(1)
      Image($r('app.media.ic_public_arrow_right')).width(16).height(16).fillColor('#CCC')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#F0F0F0' })
  }
}