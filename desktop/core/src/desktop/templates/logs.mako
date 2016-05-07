## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.lib.conf import BoundConfig
from desktop.lib.i18n import smart_unicode
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
import re
%>

<%namespace name="actionbar" file="actionbar.mako" />
<%namespace name="layout" file="about_layout.mako" />

${ commonheader(_('Server Logs'), "about", user) | n,unicode }
${layout.menubar(section='log_view')}

<style type="text/css">
  pre {
    margin: 0;
    padding: 2px;
    border: 0;
    white-space: pre-wrap;
  }

  pre.nowrap {
    white-space: nowrap;
  }

  pre.highlighted {
    background-color: #FFFF88;
  }

  #logs {
    overflow: auto;
    background-color: #F5F5F5;
  }

  #logs pre:first-child {
    padding-top: 10px;
  }

  #logs pre:last-child {
    padding-bottom: 10px;
  }

  .notFound {
    background-color: #f09999 !important;
  }
</style>

<div class="container-fluid">
  <div class="card card-small">
    <%actionbar:render>
      <%def name="search()">
        <input type="text" class="input-xxlarge search-query" placeholder="${_('Search in the logs')}" value="${query}">
      </%def>
      <%def name="creation()">
        ${ _('Host') }: <span style="display: inline-block; margin-right: 10px">${ hostname }</span>

        <label class="checkbox" for="forcedDebug" style="display: inline-block; margin-right: 10px">${_('Force DEBUG level')}</label>
        <input type="checkbox" id="forcedDebug" data-bind="checked: forcedDebug" style="vertical-align: middle">

        <label class="checkbox" for="wrap" style="display: inline-block; margin-right: 10px">${_('Wrap logs')}</label>
        <input id="wrapLogs" id="wrap" type="checkbox" checked="checked">

        <a href="/desktop/download_logs" class="btn"><i class="fa fa-download"></i> ${_('Download entire log as zip')}</a>
      </%def>
    </%actionbar:render>

    <% log.reverse() %>

    <div id="logs">
        % for l in log:
          <pre>${smart_unicode(l, errors='ignore')}</pre>
        % endfor
    </div>

  </div>

</div>

<script src="${ static('desktop/ext/js/knockout.min.js') }" type="text/javascript" charset="utf-8"></script>


<script>
  var LiveDebugging = function () {
    var self = this;

    self.forcedDebug = ko.observable();
    self.forcedDebug.subscribe(function(newValue) {
      if (newValue != null) {
        self.toggleLogLevel();
      }
    }, this, "beforeChange");

    self.getDebugLevel = function() {
      $.get("/desktop/get_debug_level", function(data) { self.forcedDebug(data.debug_all); });
    };

    self.toggleLogLevel = function() {
      var _url = "";
      if (self.forcedDebug()) {
        _url = "/desktop/set_all_debug";
      } else {
        _url = "/desktop/reset_all_debug";
      }

      $.post(_url, {}, function(data) {
        if (data,status != 0) {
          $(document).trigger("error", data.message);
        }
      }).fail(function (xhr, textStatus, errorThrown) {
        $(document).trigger("error", xhr.responseText);
      });
    };
  }

  var viewModel;

  $(document).ready(function () {
    viewModel = new LiveDebugging();
    ko.applyBindings(viewModel, $(".action-main-bar")[0]);

    viewModel.getDebugLevel();

    resizeScrollingLogs();

    var resizeTimeout = -1;
    $(window).resize(function () {
      window.clearTimeout(resizeTimeout);
      resizeTimeout = window.setTimeout(function () {
        resizeScrollingLogs();
      }, 200);
    });

    $(".search-query").jHueDelayedInput(function(){
      filterLogs($(".search-query").val());
    }, 500);

    if ("${query}" != "") {
      filterLogs("${query}");
    }

    function resizeScrollingLogs() {
      var _el = $("#logs");
      if (!$.browser.msie) {
        _el.css("overflow-y", "").css("height", "");
      }
      var heightAfter = 0;
      _el.nextAll(":visible").each(function () {
        heightAfter += $(this).outerHeight(true);
      });
      if (_el.height() > ($(window).height() - _el.offset().top - heightAfter)) {
        _el.css("overflow-y", "auto").height($(window).height() - _el.offset().top - heightAfter - 30);
      }
    }

    function filterLogs(query) {
      $(".search-query").removeClass("notFound");
      if ($.trim(query) == "") {
        $("#logs").scrollTop(0);
        return false;
      }
      $("pre.highlighted").removeClass("highlighted");
      var found = false;
      $("#logs pre").each(function () {
        var _el = $(this);
        if (_el.text().toLowerCase().replace(/\s/g, "").indexOf(query.toLowerCase().replace(/\s/g, "")) > -1) {
          _el.addClass("highlighted");
          $("#logs").scrollTop(_el.offset().top - $("#logs").position().top - 4);
          found = true;
          return false;
        }
      });
      if (!found) {
        $(".search-query").addClass("notFound");
        $("#logs").scrollTop(0);
      }
    }

    $("#wrapLogs").on("change", function(){
      if ($(this).is(":checked")){
        $("pre").removeClass("nowrap");
      }
      else {
        $("pre").addClass("nowrap");
      }
    });
  });
</script>

${ commonfooter(request, messages) | n,unicode }
