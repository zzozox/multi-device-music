/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import mediaQuery from '@ohos.mediaquery';
import { BreakpointConstants } from '../../constants/BreakpointConstants';
import { BreakpointType } from './BreakpointType';

declare interface BreakPointTypeOption<T> {
  sm?: T;
  md?: T;
  lg?: T;
  xl?: T;
  xxl?: T;
}

export class BreakPointType<T> {
  options: BreakPointTypeOption<T>;

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option;
  }

  getValue(currentBreakPoint: string) {
    if (currentBreakPoint === BreakpointConstants.BREAKPOINT_SM) {
      return this.options.sm;
    } else if (currentBreakPoint === BreakpointConstants.BREAKPOINT_MD) {
      return this.options.md;
    } else if (currentBreakPoint === BreakpointConstants.BREAKPOINT_LG) {
      return this.options.lg;
    } else {
      return undefined;
    }
  }
}

interface Breakpoint {
  name: string;
  size: number;
  mediaQueryListener?: mediaQuery.MediaQueryListener;
}

export class BreakpointSystem {
  private currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  private breakpoints: Breakpoint[] = [
    {
      name: BreakpointConstants.BREAKPOINT_XS,
      size: BreakpointConstants.BREAKPOINT_SCOPE[0]
    },
    {
      name: BreakpointConstants.BREAKPOINT_SM,
      size: BreakpointConstants.BREAKPOINT_SCOPE[1]
    }
    ,
    {
      name: BreakpointConstants.BREAKPOINT_MD,
      size: BreakpointConstants.BREAKPOINT_SCOPE[2]
    },
    {
      name: BreakpointConstants.BREAKPOINT_LG,
      size: BreakpointConstants.BREAKPOINT_SCOPE[3]
    }
  ];

  private updateCurrentBreakpoint(breakpoint: string) {
    if (this.currentBreakpoint !== breakpoint) {
      BreakpointType.currentBreakpoint = breakpoint;
      this.currentBreakpoint = breakpoint;
      AppStorage.set<string>('currentBreakpoint', this.currentBreakpoint);
    }
  };

  public register() {
    this.breakpoints.forEach((breakpoint: Breakpoint, index) => {
      let condition: string;
      if (index === this.breakpoints.length - 1) {
        condition = '(' + breakpoint.size + 'vp<=width' + ')';
      } else {
        condition = '(' + breakpoint.size + 'vp<=width<' + this.breakpoints[index + 1].size + 'vp)';
      }
      breakpoint.mediaQueryListener = mediaQuery.matchMediaSync(condition);
      breakpoint.mediaQueryListener.on('change', (mediaQueryResult) => {
        if (mediaQueryResult.matches) {
          this.updateCurrentBreakpoint(breakpoint.name);
        }
      })
    })
  };

  public unregister() {
    this.breakpoints.forEach((breakpoint: Breakpoint) => {
      if (breakpoint.mediaQueryListener) {
        breakpoint.mediaQueryListener.off('change');
      }
    })
  };
}