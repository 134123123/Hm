@Component
export struct HistoryPage {
  build() {
    Column() {
      // Header
      Row() {
        Image($r('app.media.ic_public_arrow_left')).width(24).height(24).fillColor(Color.White)
        Text('古今').fontSize(18).fontColor(Color.White).layoutWeight(1).textAlign(TextAlign.Center)
        Image($r('app.media.ic_public_arrow_left')).width(24).height(24).opacity(0)
      }
      .height(50)
      .width('100%')
      .backgroundColor('#5B8FF9')
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          // 数字日期展示区
          Row() {
            ForEach(['2','2','2','2',',','2','2',',','2','2'], (char: string) => {
              Text(char)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .backgroundColor(char === ',' ? Color.Transparent : '#F0F0F0')
                .padding(4)
                .margin(2)
                .borderRadius(4)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 20, bottom: 20 })
          .backgroundColor(Color.White)

          Text('节日 农历七月廿五')
            .fontSize(16)
            .width('90%')
            .margin({ top: 10, bottom: 10 })

          Column({ space: 20 }) {
            this.HistoryItem('生日', '龚自珍（清朝思想家、文学家）\n德彪西（Achille-Claude Debussy，法国作曲家）')
            this.HistoryItem('961', '宋太祖阿巴阿巴。')
            this.HistoryItem('1642', '英国内战爆发。')
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }

  @Builder HistoryItem(title: string, content: string) {
    Row() {
      Text(title).fontSize(18).fontWeight(FontWeight.Bold).width(60).fontColor('#333')
      Text(content).fontSize(16).fontColor('#666').layoutWeight(1).lineHeight(24)
    }.alignItems(VerticalAlign.Top)
    .width('100%')
  }
}