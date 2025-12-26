import router from '@ohos.router';
import http from '@ohos.net.http';
import { NoteModel } from '../model/NoteModel';

// 泛型响应类
class ResponseResult<T> {
  code: number; msg: string; data: T;
  constructor(code: number, msg: string, data: T) { this.code = code; this.msg = msg; this.data = data; }
}

@Entry
@Component
struct CategoryNoteListPage {
  @State categoryName: string = ''
  @State categoryId: number = 0
  @State notes: NoteModel[] = []

  private baseUrl: string = 'http://192.168.63.229:8080';
  @StorageProp('loginUserId') currentUserId: number = 0;

  aboutToAppear() {
    let params = router.getParams() as Record<string, Object>;
    if (params) {
      this.categoryId = params.categoryId as number;
      this.categoryName = params.categoryName as string;
      this.loadNotes();
    }
  }

  loadNotes() {
    let httpRequest = http.createHttp();
    // 调用后端新接口
    let url = `${this.baseUrl}/note/listByCategory?userId=${this.currentUserId}&categoryId=${this.categoryId}`;

    httpRequest.request(url, { method: http.RequestMethod.GET }, (err, data) => {
      if (!err && data.responseCode === 200) {
        let res = JSON.parse(data.result.toString()) as ResponseResult<NoteModel[]>;
        if (res.code === 1) {
          this.notes = res.data || [];
        }
      }
    });
  }

  build() {
    Column() {
      // 顶部导航栏 (带返回)
      Row() {
        Image($r('app.media.ic_public_arrow_left')) // 确保有这个左箭头图标
          .width(24).height(24).fillColor('#333')
          .onClick(() => router.back())

        Text(this.categoryName)
          .fontSize(20).fontColor('#333').fontWeight(FontWeight.Bold).margin({ left: 16 })
      }
      .width('100%').height(56).backgroundColor(Color.White).padding({ left: 16 })
      .shadow({ radius: 2, color: 'rgba(0,0,0,0.03)', offsetY: 2 })

      // 列表内容
      if (this.notes.length === 0) {
        Column() {
          Image($r('app.media.ic_public_folder')).width(60).height(60).fillColor('#DDD')
          Text('此分类下暂无笔记').fontSize(14).fontColor('#999').margin({ top: 10 })
        }.width('100%').height('60%').justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.notes, (item: NoteModel) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333')
                  Blank()
                  if (item.isEncrypted === 1) {
                    Image($r('app.media.ic_public_lock')).width(16).height(16).fillColor('#999')
                  }
                }.width('100%')

                // 内容预览
                Text((item.content || '').substring(0, 50).replace('\n', ' '))
                  .fontSize(14).fontColor('#666').maxLines(2).textOverflow({overflow: TextOverflow.Ellipsis})

                Text((item.createTime || '').substring(0, 16)).fontSize(12).fontColor('#CCC').margin({ top: 4 })
              }
              .padding(16).backgroundColor(Color.White).borderRadius(12)
              .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            }
            .onClick(() => {
              // 点击进入编辑页
              router.pushUrl({
                url: 'pages/NoteEditPage',
                params: { noteId: item.id, title: item.title, content: item.content, isLocked: item.isEncrypted }
              })
            })
          })
        }
        .width('94%').layoutWeight(1).margin({ top: 12 })
      }
    }
    .width('100%').height('100%').backgroundColor('#F8F9FA')
  }
}