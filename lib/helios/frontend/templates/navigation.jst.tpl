<ul class="button-group">
  <% if(Helios.services['data']) { %>
    <li class="button">
      <a href="#data"><i class="data"/> Data</a>
    </li>
  <% } %>

  <% if(Helios.services['push-notification']) { %>
    <li class="button">
      <a href="#push-notification"><i class="push-notification"/> Push Notification</a>
    </li>
  <% } %>

  <% if(Helios.services['gcm']) { %>
    <li class="button">
      <a href="#gcm"><i class="gcm"/> Google Cloud Message</a>
    </li>
  <% } %>

  <% if(Helios.services['in-app-purchase']) { %>
    <li class="button">
      <a href="#in-app-purchase"><i class="in-app-purchase"/> In-App Purchase</a>
    </li>
  <% } %>

  <% if(Helios.services['passbook']) { %>
    <li class="button">
      <a href="#passbook"><i class="passbook"/> Passbook</a>
    </li>
  <% } %>

  <% if(Helios.services['newsstand']) { %>
    <li class="button">
      <a href="#newsstand"><i class="data"/> Newsstand</a>
    </li>
  <% } %>
</ul>
