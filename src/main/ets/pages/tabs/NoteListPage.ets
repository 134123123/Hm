import { NoteItem } from '../../model/Models'

@Component
export struct NoteListPage {
  // 模拟数据
  @State notes: NoteItem[] = [
    new NoteItem('1', 'OKOK', '2022年8月17日 中午12:02', false),
    new NoteItem('2', '你好你好', '2022年8月17日 中午12:00', false),
    new NoteItem('3', '私密日记', '2022年8月18日 下午14:00', true)
  ]

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // 顶部 Header
        Row() {
          Image($r('app.media.ic_public_arrow_left')).width(24).height(24).fillColor(Color.White)
          Text('列表').fontSize(18).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
          Image($r('app.media.ic_public_arrow_left')).width(24).height(24).opacity(0) // 占位保持标题居中
        }
        .height(50)
        .width('100%')
        .backgroundColor('#5B8FF9')
        .padding({ left: 16, right: 16 })

        // 搜索框
        Row() {
          Image($r('app.media.ic_public_search')).width(20).height(20).fillColor('#999')
          Text(' 搜索...').fontSize(14).fontColor('#999')
        }
        .width('92%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .margin({ top: 10, bottom: 10 })
        .padding({ left: 12 })
        .alignItems(VerticalAlign.Center)

        // 笔记列表
        List({ space: 10 }) {
          ForEach(this.notes, (item: NoteItem) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                  Blank()
                  if (item.isLocked) {
                    Image($r('app.media.ic_public_lock')).width(16).height(16).fillColor('#999')
                  }
                  Image($r('app.media.ic_public_more')).width(20).height(20).margin({ left: 8 })
                }
                .width('100%')

                Text(item.date)
                  .fontSize(12)
                  .fontColor('#999')
                  .margin({ top: 8 })
              }
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .width('100%')
              .shadow({ radius: 4, color: '#10000000', offsetY: 2 })
            }
          })
        }
        .width('92%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FAFAFA')

      // 右下角悬浮按钮
      Column({ space: 16 }) {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r('app.media.ic_public_refresh')).width(24).height(24).fillColor(Color.White)
        }
        .width(50).height(50).backgroundColor('#8EA0E6')

        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Image($r('app.media.ic_public_edit')).width(24).height(24).fillColor(Color.White)
        }
        .width(50).height(50).backgroundColor('#5B8FF9')
      }
      .margin({ right: 20, bottom: 30 })
    }
  }
}