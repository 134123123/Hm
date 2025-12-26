// src/main/ets/model/Models.ets
export class NoteItem {
  id: string;
  title: string;
  date: string;
  isLocked: boolean;

  constructor(id: string, title: string, date: string, isLocked: boolean = false) {
    this.id = id;
    this.title = title;
    this.date = date;
    this.isLocked = isLocked;
  }
}

export class CategoryItem {
  id: string;
  name: string;
  count: number;

  constructor(id: string, name: string, count: number) {
    this.id = id;
    this.name = name;
    this.count = count;
  }
}