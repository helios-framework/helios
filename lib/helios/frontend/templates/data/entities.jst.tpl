<div class="auxiliary">
  <h2>Data</h2>
  <a id="entities-dropdown" data-dropdown="entities" class="button dropdown">Entities</a>
  <ul id="entities" class="f-dropdown">
    <% _.each(entities.models, function(entity) { %>
      <li><a href="#<%= entity.url() %>"><%= entity.get('name') %></a></li>
    <% }) %>
  </ul>
</div>

<div id="datagrid" class="master"></div>
