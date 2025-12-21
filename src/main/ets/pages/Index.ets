import { NoteListPage } from './tabs/NoteListPage'
import { CategoryPage } from './tabs/CategoryPage'
import { HistoryPage } from './tabs/HistoryPage'
import { MinePage } from './tabs/MinePage' // 确保你创建了这个文件

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  // 自定义 TabBar 构建器
  @Builder TabBuilder(title: string, index: number, iconNormal: Resource, iconSelected: Resource) {
    Column() {
      Image(this.currentIndex === index ? iconSelected : iconNormal)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .fontColor(this.currentIndex === index ? '#5B8FF9' : '#999999')
        .fontSize(10)
        .margin({ top: 4 })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .onClick(() => {
      this.currentIndex = index
      this.controller.changeIndex(index)
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.controller }) {

      // 1. 列表页
      TabContent() {
        NoteListPage()
      }
      .tabBar(this.TabBuilder('列表', 0, $r('app.media.icon_list_gray'), $r('app.media.icon_list_blue')))

      // 2. 分类页
      TabContent() {
        CategoryPage()
      }
      .tabBar(this.TabBuilder('分类', 1, $r('app.media.icon_cat_gray'), $r('app.media.icon_cat_blue')))

      // 3. 古今页
      TabContent() {
        HistoryPage()
      }
      .tabBar(this.TabBuilder('古今', 2, $r('app.media.icon_history_gray'), $r('app.media.icon_history_blue')))

      // 4. 我的页
      TabContent() {
        MinePage()
      }
      .tabBar(this.TabBuilder('我的', 3, $r('app.media.icon_me_gray'), $r('app.media.icon_me_blue')))
    }
    .scrollable(false)
    .barHeight(60)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }
}