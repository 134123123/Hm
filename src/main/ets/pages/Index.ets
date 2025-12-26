// src/main/ets/pages/Index.ets
import router from '@ohos.router';
import { NoteListPage } from './tabs/NoteListPage';
import promptAction from '@ohos.promptAction';
import { CategoryPage } from './tabs/CategoryPage';
import { HistoryPage } from './tabs/HistoryPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0

  // ✅ 从全局存储获取用户信息
  @StorageProp('loginUserName') currentUserName: string = '未登录';
  @StorageProp('loginNickName') currentNickName: string = '普通用户';

  // 自定义 TabBar 构建函数
  @Builder TabBarBuilder(title: string, index: number, icon: Resource, selectedIcon: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedIcon : icon)
        .width(24).height(24)
      Text(title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? '#5B8FF9' : '#999999')
        .margin({ top: 4 })
    }.justifyContent(FlexAlign.Center).height('100%').width('100%')
  }

  // 通用的“我的”列表项构建器
  @Builder MineItem(title: string, icon: Resource, onClick?: () => void) {
    Row() {
      Image(icon).width(24).height(24).fillColor('#5B8FF9').margin({ right: 12 })
      Text(title).fontSize(16).fontColor('#333')
      Blank()
      Image($r('app.media.ic_public_arrow_right')).width(16).height(16).fillColor('#CCC')
    }
    .width('100%').height(56).backgroundColor(Color.White).padding({ left: 16, right: 16 })
    .border({ width: { bottom: 1 }, color: '#F5F5F5' })
    .onClick(() => {
      if (onClick) onClick();
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {

      // === Tab 1: 列表 (引用 NoteListPage 组件) ===
      TabContent() {
        NoteListPage()
      }
      .tabBar(this.TabBarBuilder('列表', 0, $r('app.media.ic_public_view_list_filled'), $r('app.media.ic_public_view_list')))

      // 2. 分类页 Tab
      TabContent() {
        CategoryPage()
      }
      .tabBar(this.TabBarBuilder('分类', 1, $r('app.media.ic_public_folder'), $r('app.media.ic_public_folder_filled')))

      // 3. 古今页 Tab
      TabContent() {
        HistoryPage() // <--- 替换这里
      }
      .tabBar(this.TabBarBuilder('古今', 2, $r('app.media.ic_public_time'), $r('app.media.ic_public_time_filled')))

      // === Tab 4: 我的 ===
      TabContent() {
        Column() {
          // 1. 蓝色头部 (显示动态用户信息)
          Column() {
            Text('我的').fontSize(20).fontColor(Color.White).margin({ top: 10 })
            Row() {
              Image($r('app.media.ic_public_input_user'))
                .width(60).height(60).borderRadius(30).backgroundColor('#FFFFFF80')
                .fillColor(Color.White)

              Column() {
                // ✅ 这里显示真实数据
                Text(this.currentUserName)
                  .fontSize(22).fontColor(Color.White).fontWeight(FontWeight.Bold)
                Text(this.currentNickName)
                  .fontSize(14).fontColor('#E0E0E0').margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
            }
            .width('100%').padding({ left: 24, top: 30 })
          }
          .width('100%').height(200).backgroundColor('#5B8FF9')

          // 2. 菜单列表
          Column() {
            // 记账本
            this.MineItem('记账本', $r('app.media.ic_public_view_list_filled'), () => {
              router.pushUrl({ url: 'pages/AccountPage' })
            })

            // 我的分类 (暂时弹窗)
            this.MineItem('我的分类', $r('app.media.ic_public_folder_filled'), () => {
              // 暂时先提示，后续开发分类页再跳转
              promptAction.showToast({ message: '分类功能开发中...' })
            })

            // 修改密码 (✅ 跳转到修改密码页)
            this.MineItem('修改密码', $r('app.media.ic_public_lock'), () => {
              router.pushUrl({ url: 'pages/ModifyPasswordPage' })
            })

            // 关于 (暂时弹窗)
            this.MineItem('关于', $r('app.media.ic_public_more'), () => {
              promptAction.showToast({ message: '当前版本 v1.0' })
            })
          }
          .margin({ top: 10 })

          // 3. 退出登录按钮
          Button('退出登录')
            .width('90%').height(50).backgroundColor('#FF4D4F')
            .margin({ top: 40 })
            .onClick(() => {
              // 清除登录信息并返回登录页
              AppStorage.SetOrCreate('loginUserId', 0);
              router.replaceUrl({ url: 'pages/LoginPage' });
            })
        }
        .width('100%').height('100%').backgroundColor('#F5F5F5')
      }
      .tabBar(this.TabBarBuilder('我的', 3, $r('app.media.ic_public_input_user_filled'), $r('app.media.ic_public_input_user')))
    }
    .onChange((index) => {
      this.currentIndex = index
    })
  }
}