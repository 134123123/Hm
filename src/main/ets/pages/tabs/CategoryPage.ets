import { CategoryItem } from '../../model/Models'

@Component
export struct CategoryPage {
  @State categories: CategoryItem[] = [
    new CategoryItem('1', '你好', 0),
    new CategoryItem('2', '嘟嘟嘟', 1)
  ]
  @State newCategoryName: string = ''

  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_public_arrow_left')).width(24).height(24).fillColor(Color.White)
        Text('分类').fontSize(18).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
        Image($r('app.media.ic_public_arrow_left')).width(24).height(24).opacity(0)
      }
      .height(50)
      .width('100%')
      .backgroundColor('#5B8FF9')
      .padding({ left: 16, right: 16 })

      // 新增分类栏
      Row() {
        TextInput({ placeholder: '请输入新分类名称', text: this.newCategoryName })
          .layoutWeight(1)
          .backgroundColor(Color.White)
          .onChange((val) => this.newCategoryName = val)

        Button('新增')
          .type(ButtonType.Normal)
          .borderRadius(4)
          .backgroundColor('#5B8FF9')
          .height(36)
          .margin({ left: 10 })
          .onClick(() => {
            if(this.newCategoryName) {
              this.categories.push(new CategoryItem('3', this.newCategoryName, 0))
              this.newCategoryName = ''
            }
          })
      }
      .padding(10)
      .backgroundColor(Color.White)
      .width('100%')

      Text('长按可编辑/删除分类')
        .fontSize(10)
        .fontColor('#999')
        .padding({ left: 10, top: 5, bottom: 5 })
        .width('100%')

      // 列表
      List() {
        ForEach(this.categories, (item: CategoryItem) => {
          ListItem() {
            Row() {
              Image($r('app.media.ic_public_folder_filled'))
                .width(24).height(24)
                .fillColor('#5B8FF9')
                .margin({ right: 10 })

              Text(item.name).fontSize(16).layoutWeight(1)

              Row() {
                Text(item.count.toString()).fontSize(14).fontColor('#999')
                Image($r('app.media.ic_public_arrow_right')).width(16).height(16).fillColor('#CCC')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .border({ width: { bottom: 1 }, color: '#F0F0F0' })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FAFAFA')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}