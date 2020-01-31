// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import * as ko from 'knockout';

import componentUtils from '../componentUtils';
import I18n from 'utils/i18n';
import DisposableComponent from '../DisposableComponent';

// prettier-ignore
const TEMPLATE = `
  <!-- ko if: window.HAS_LINK_SHARING && perms() -->
    <!-- ko ifnot: perms().link_sharing_on -->
      <a href="javascript:void(0);" data-bind="click: createReadLink" title="${ I18n('Share the query via a link') }" >
        <i class="fa fa-wf fa-link"></i> ${ I18n('Get link') }
      </a>
    <!-- /ko -->
    <!-- ko if: perms().link_sharing_on -->
      <a href="javascript:void(0)" data-bind="click: deactivateLink" title="${ I18n('Deactivate the link sharing') }">
        <i class="fa fa-wf fa-link"></i> ${ I18n('Deactivate link') }
      </a>
      
      <div class="row-fluid">
        <div class="span12">
          ${ I18n('Anyone logged and with the link can:') }
          <!-- ko component: { 
            name: 'hue-drop-down',
            params: {
              value: permission,
              entries: availablePermissions
            } 
          } --><!-- /ko -->
          <br/>
          ${ I18n('Read') }: <span data-bind="text: perms().link_read"></span> |
          ${ I18n('Write') }: <span data-bind="text: perms().link_write"></span>
        </div>
      </div>
    <!-- /ko -->
  <!-- /ko -->
`;

const READ_OPTION = I18n('Read');
const WRITE_OPTION = I18n('Write');

class LinkSharing extends DisposableComponent {
  constructor(params) {
    super();
    this.perms = params.perms;
    this.docUuid = params.uuid;
    this.permission = ko.observable();
    this.availablePermissions = [READ_OPTION, WRITE_OPTION];

    if (this.perms()) {
      this.permission(this.perms().link_read ? READ_OPTION : WRITE_OPTION);
    }

    super.subscribe(this.perms, perms =>
      this.permission(perms.link_read ? READ_OPTION : WRITE_OPTION)
    );
  }

  createReadLink() {
    console.log('hello 1');
  }

  deactivateLink() {
    console.log('hello 2');
  }
}

componentUtils.registerComponent('link-sharing', LinkSharing, TEMPLATE);
