export class NoteModel {
  id: number
  title: string
  content: string
  createTime: string
  isLocked: boolean

  // 🔥 新增这个字段，对应后端的 isEncrypted
  isEncrypted: number

  constructor(id: number, title: string, content: string, createTime: string, isLocked: boolean, isEncrypted: number) {
    this.id = id
    this.title = title
    this.content = content
    this.createTime = createTime
    this.isLocked = isLocked
    this.isEncrypted = isEncrypted
  }
}