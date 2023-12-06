# 卡片介绍
实现文件管理相关的操作，包括应用文件保存与读取，用户文件图片读取，txt文档读取保存操作。便于用户根据codelab学习如何操作文件管理。
# 标题
文件管理（ArkTS）
# 介绍
本篇Codelab介绍了如何实现文件管理的相关操作，主要功能包括：
1. 用户可以向沙箱路径下的某个文件（test.txt）写入数据并支持读取，完成对沙箱路径下文件的读写功能。
2. 用户可以读取图库内图片并展示在项目中，以及将一张图片保存到图库中，完成对图库的读写功能。
3. 可以将沙箱路径下的某个文件（test.txt）中的内容保存到用户目录下新建的文件中，并可以通过选择来读取出用户目录下文件的内容，完成对用户目录文件的读写功能。
   本应用的运行效果如下图所示：
   ![](figures/效果展示.gif)
## 相关概念
- [文件管理能力](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-fs-0000001630146185-V4) ：该模块为基础文件操作API，提供基础文件操作能力，包括文件基本管理、文件目录管理、文件信息统计、文件流式读写等常用功能。（@ohos.file.fs）
- [选择器](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__photoviewpicker) ： 选择器(Picker)是一个封装PhotoViewPicker、DocumentViewPicker、AudioViewPicker等API模块，具有选择与保存的能力。（@ohos.file.picker）
- [相册管理模块](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-photoaccesshelper-0000001657915457-V4) ：该模块提供相册管理模块能力，包括创建相册以及访问、修改相册中的媒体数据信息等。（@ohos.file.photoAccessHelper）
- [PhotoViewPicker](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__photoviewpicker) ：图库选择器对象，用来支撑选择图片/视频和保存图片/视频等用户场景。
- [DocumentViewPicker](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__documentviewpicker) ：文件选择器对象，用来支撑选择和保存各种格式文档。
- [使用安全控件创建媒体资源](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V4/photoaccesshelper-resource-guidelines-0000001657835481-V4#ZH-CN_TOPIC_0000001666548576__使用安全控件创建媒体资源) ：使用安全控件创建媒体资源无需在应用中申请相册管理模块权限'ohos.permission.WRITE_IMAGEVIDEO'。

## 环境搭建

### 软件要求

-   [DevEco Studio](https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/quick-start/start-overview.md#%E5%B7%A5%E5%85%B7%E5%87%86%E5%A4%87)版本：DevEco Studio 3.1 Release。
-   [HarmonyOS SDK](https://developer.harmonyos.com/cn/develop/harmonyos-sdk)版本：API version 9及以上版本。

### 硬件要求

-   设备类型：华为手机或运行在DevEco Studio上的华为手机设备模拟器。
-   HarmonyOS系统：3.1.0 Developer Release及以上版本。

### 环境搭建

1. 安装DevEco Studio，详情请参考[下载和安装软件](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ide_debug_emulator-0000001115721921-V3?catalogVersion=V3)。
2. 设置DevEco Studio开发环境，DevEco Studio开发环境需要依赖于网络环境，需要连接上网络才能确保工具的正常使用，可以根据如下两种情况来配置开发环境：
   1. 如果可以直接访问Internet，只需进行[下载HarmonyOS SDK](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ide_debug_emulator-0000001115721921-V3?catalogVersion=V3)操作。
   2. 如果网络不能直接访问Internet，需要通过代理服务器才可以访问，请参考[配置开发环境](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ide_debug_emulator-0000001115721921-V3?catalogVersion=V3)。
3. 开发者可以参考以下链接，完成设备调试的相关配置：
   1. [使用真机进行调](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ide_debug_emulator-0000001115721921-V3?catalogVersion=V3)
   2. [使用模拟器进行调试](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/ide_debug_emulator-0000001115721921-V3?catalogVersion=V3)

## 代码结构解读

```
├──entry/src/main/ets                      // 代码区
│  ├──common
│  │  └──utils
│  │     ├──Logger.ets                     // 日志打印类
│  │     ├──PictureSaving.ets              // 图片保存方法
│  │     ├──ReadFile.ets                   // 文件读取方法
│  │     ├──SavingAndSelectUserFile.ets    // 用户文件保存与选择方法
│  │     └──WriteFile.ets                  // 文件写入方法
│  ├──entryability
│  │  └──EntryAbility.ts                   // 程序入口类
│  ├──pages
│  │  └──HomePage.ets                      // 主界面	
│  └──view
│     ├──ApplicationFileTab.ets            // 应用文件功能展示
│     └──PublicFilesTab.ets                // 公共文件功能展示
└──entry/src/main/resources                // 资源文件目录
```

## 沙箱路径下的文件读写
对文件的读写操作本质上都是获取想要操作文件的uri，然后利用[@ohos.file.fs](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-fs-0000001630146185-V4)提供的方法进行操作。
1. 实现沙箱路径下文件的写入操作
   1. 首先需要结合context得到想要操作的文件路径。
   2. 然后对该文件进行写入操作，这里使用的是[fs.createStream](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-fs-0000001630146185-V4#ZH-CN_TOPIC_0000001714586817__fscreatestream)创建文件流的形式。
   3. 通过文件流的方式可以控制文件的读写方式，覆盖写的方式可以使得每次写操作互不影响。
```typescript
// WriteFile.ets
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

export function writeFile(content: string): void {
  let filePath = filesDir + '/test.txt';
  // Open a file stream based on the file path.
  let fileStream = fs.createStreamSync(filePath, "w+");
  fileStream.writeSync(content)
  fileStream.close()
}
```
2. 实现沙箱路径下文件的读取操作，与写入类似，也通过文件路径去创建文件流，进行读取操作。
   1. 通过fs.statSync获取文件的详细信息,进而得到文件内容的大小
   2. 然后利用文件流将文件内容读取到ArrayBuffer中，再将ArrayBuffer转化为string返回，即可完成文件的读取操作。
```typescript
// ReadFile.ets
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import buffer from '@ohos.buffer';

// Obtaining the Application File Path
let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;
let res: string = '';

export function readFile(): string {
  let filePath = filesDir + '/test.txt';
  let stat = fs.statSync(filePath);
  let size = stat.size;
  let buf = new ArrayBuffer(size);
  // Open a file stream based on the file path.
  let fileStream = fs.createStreamSync(filePath, "r+");
  // File stream reading information
  fileStream.readSync(buf);
  // Converts the read information to the string type and returns the string type.
  let con = buffer.from(buf, 0);
  res = con.toString();
  fileStream.close()
  return res;
}
```
## 图库的读取与写入
1. 从图库中选择一种图片进行展示
- 调用PhotoViewPicker的select方法来得到被选择图片的uri，即可完成读取图库中图片的信息。
```typescript
// PictureSaving.ets
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import Logger from './Logger';


// Defines a URI array, which is used to receive the URI returned by PhotoViewPicker for selecting images.
let uris: Array<string> = [];

// Invoke PhotoViewPicker.select to select an image.
export async function photoPickerGetUri(): Promise<string> {
  try {
    let PhotoSelectOptions = new picker.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 1;
    let photoPicker = new picker.PhotoViewPicker();
    await photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: picker.PhotoSelectResult) => {
      Logger.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      uris = PhotoSelectResult.photoUris;
    }).catch((err: BusinessError) => {
      Logger.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    Logger.error('PhotoViewPicker failed with err: ' + err.message);
  }
  return uris[0].toString();
}
```
2. 保存一张图片到图库
- 该功能的实现需要逐步完成如下操作：
   1. 在图库中创建媒体资源
   2. 将图片读取转化为ArrayBuffer
   3. 将该内容写入在图库中创建的媒体资源中
```typescript
// PublicFilesTab.ets
SaveButton(this.saveButtonOptions)
  .onClick(async (event, result: SaveButtonOnClickResult) => {
    if (result == SaveButtonOnClickResult.SUCCESS) {
      try {
        let context = getContext();
        let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
        // Creating a Media File
        let uri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
        Logger.info('createAsset successfully, uri: ' + uri);
        // Open the created media file and read the local file and convert it to ArrayBuffer for easy filling.
        let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
        let buffer = getContext(this).resourceManager.getMediaContentSync($r('app.media.img').id);
        // Write the read ArrayBuffer to the new media file.
        let writeLen = await fs.write(file.fd, buffer.buffer);
        Logger.info('write success,writelen=' + writeLen);
        await fs.close(file);
      } catch (err) {
        Logger.error('createAsset failed, message = ', err);
      }
    } else {
      Logger.error('SaveButtonOnClickResult createAsset failed');
    }
  })
```
[createAsset](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-photoaccesshelper-0000001657915457-V4#ZH-CN_TOPIC_0000001666548756__createasset)方法会返回在图库中新建的媒体资源的uri，只不过此时还是没有内容的空文件，然后需要将本地图片文件的内容读取出来，并写入该空文件，即可完成图片保存到图库的操作。
## 用户目录的文件读写
用户目录文件主要展示对文本文件的处理，基于[DocumentViewPicker](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__documentviewpicker)，能够基本完成对文件的保存与选择。
1. 用户文件的保存
   在DocumentViewPicker提供的[save](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__save-3)方法的帮助下，我们可以向用户目录下创建一个文件并返回它的uri。
```typescript
// SavingAndSelectUserFile.ets
export async function saveToUser(content: string) {
  try {
    let DocumentSaveOptions = new picker.DocumentSaveOptions();
    DocumentSaveOptions.newFileNames = ['test.txt'];
    let documentPicker = new picker.DocumentViewPicker();
    documentPicker.save(DocumentSaveOptions).then((DocumentSaveResult: Array<string>) => {
      Logger.info('DocumentViewPicker.save successfully, DocumentSaveResult uri: ' + JSON.stringify(DocumentSaveResult));
      uri = DocumentSaveResult[0];
      let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
      // Open a file stream based on the file path.
      fs.writeSync(file.fd, content);
    }).catch((err: BusinessError) => {
      Logger.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    Logger.error('DocumentViewPicker failed with err: ' + err.message);
  }
}
```
2. 用户文件的选择
   在DocumentViewPicker提供的[select](https://developer.harmonyos.com/cn/docs/documentation/doc-references-V4/js-apis-file-picker-0000001630425513-V4#ZH-CN_TOPIC_0000001666706972__select-3)方法的帮助下，我们可以选择想要访问的文件，并返回其uri。
```typescript
// SavingAndSelectUserFile.ets
export async function readUserFile(): Promise<string> {
  try {
    let DocumentSelectOptions = new picker.DocumentSelectOptions();
    let documentPicker = new picker.DocumentViewPicker();
    await documentPicker.select(DocumentSelectOptions).then((DocumentSelectResult: Array<string>) => {
      Logger.info('DocumentViewPicker.select successfully, DocumentSelectResult uri: ' + JSON.stringify(DocumentSelectResult));
      uri = DocumentSelectResult[0];
      let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
      let stat = fs.statSync(file.fd);
      let size = stat.size;
      let buf = new ArrayBuffer(size);
      fs.readSync(file.fd, buf);
      let con = buffer.from(buf, 0);
      message = con.toString();
    }).catch((err: BusinessError) => {
      Logger.error('DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    Logger.error('DocumentViewPicker failed with err: ' + err.message);
  }
  return message;
}
```
获取到uri后，即可完成对文件的读取，并将信息返回的操作。

## 总结

您已经完成了本次Codelab的学习，并了解到以下知识点：
1. 基本的文件读写操作。
2. 对用户文件的读写能力。

![](figures/彩带动效.gif)
