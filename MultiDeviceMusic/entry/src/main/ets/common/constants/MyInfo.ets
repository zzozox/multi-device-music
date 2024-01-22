export class MyInfo {
  image: ResourceStr = $r('app.media.touxiang');
  name: string = '周芷璇';
  password: string = '123456';
  sex: string = '女';
  age: number = 20;
  content: string = '没有任何描述';

  updateInfo(newInfo: Partial<MyInfo>) {
    Object.assign(this, newInfo);
  }
}
export const myInfo = new MyInfo();