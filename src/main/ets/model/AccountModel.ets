// src/main/ets/model/AccountModel.ets

export class AccountModel {
  id: number
  userId: number
  title: string
  type: string      // 'out' 或 'in'
  amount: number    // 金额
  remark: string
  createTime: string // "2023-12-21 12:00:00"

  constructor(id: number, userId: number, title: string, type: string, amount: number, remark: string, createTime: string) {
    this.id = id
    this.userId = userId
    this.title = title
    this.type = type
    this.amount = amount
    this.remark = remark
    this.createTime = createTime
  }
}