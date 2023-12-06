/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import taskpool from '@ohos.taskpool';
import { AdjustId, ItaskArgs } from '../viewModel/OptionViewModel';
import { adjustImageValue, adjustSaturation } from './AdjustUtil';
import { CommonConstants } from '../common/constant/CommonConstants';

export function mergeArrayBuffers(buffers: ArrayBuffer[]) {
  let totalLength: number = buffers.reduce((length: number, buffer: ArrayBuffer): number => {
    length += buffer.byteLength;
    return length;
  }, 0);
  let mergedBuffer = new ArrayBuffer(totalLength);
  let mergedArray = new Uint8Array(mergedBuffer);
  let offset = 0;
  for (let buffer of buffers) {
    let array = new Uint8Array(buffer);
    mergedArray.set(array, offset);
    offset += array.length;
  }
  return mergedBuffer;
}

@Concurrent
async function imageProcessing(args: ItaskArgs): Promise<ArrayBuffer> {
  if (args.type === AdjustId.BRIGHTNESS) {
    return adjustImageValue(args.bufferArray, args.sliderValue, args.value);
  }
  return adjustSaturation(args.bufferArray, args.sliderValue, args.value);
}

export function splitArrayBuffer(buffer: ArrayBuffer, taskCount: number): ArrayBuffer[] {
  let num = Math.floor(buffer.byteLength / taskCount);
  while (num % CommonConstants.PIXEL_STEP !== 0) {
    num += 1;
  }
  let result: ArrayBuffer[] = [];
  for (let index = 0; index < taskCount; index++) {

    if (index === taskCount - 1) {
      result[index] = buffer.slice(index * num)
    } else {
      result[index] = buffer.slice(index * num, (index + 1) * num)
    }
  }
  return result;
}

export function splitTask(buffers: ArrayBuffer[], type: AdjustId, sliderValue: number, value: number): taskpool.TaskGroup {
  let group: taskpool.TaskGroup = new taskpool.TaskGroup();
  for (const buffer of buffers) {
    let obj: ItaskArgs = {
      type,
      bufferArray: buffer,
      sliderValue,
      value
    };
    group.addTask(imageProcessing, obj);
  }
  return group;
}