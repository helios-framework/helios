// backbone.datagrid v0.3.2
//
// Copyright (c) 2012 Loïc Frering <loic.frering@gmail.com>
// Distributed under the MIT license

(function() {

var Datagrid = Backbone.View.extend({
  initialize: function() {
    this.columns = this.options.columns;
    this.options = _.defaults(this.options, {
      paginated:      false,
      page:           1,
      perPage:        10,
      tableClassName: 'table',
      emptyMessage:   '<p>No results found.</p>'
    });

    this.collection.on('reset', this.render, this);
    this._prepare();
  },

  render: function() {
    this.$el.empty();
    this.renderTable();
    if (this.options.paginated) {
      this.renderPagination();
    }

    return this;
  },

  renderTable: function() {
    var $table = $('<table></table>', {'class': this.options.tableClassName});
    this.$el.append($table);

    var header = new Header({columns: this.columns, sorter: this.sorter});
    $table.append(header.render().el);

    $table.append('<tbody></tbody>');

    if (this.collection.isEmpty()) {
      this.$el.append(this.options.emptyMessage);
    } else {
      this.collection.forEach(this.renderRow, this);
    }
  },

  renderPagination: function() {
    var pagination = new Pagination({pager: this.pager});
    this.$el.append(pagination.render().el);
  },

  renderRow: function(model) {
    var options = {
      model: model,
      columns: this.columns
    };
    var rowClassName = this.options.rowClassName;
    if (_.isFunction(rowClassName)) {
      rowClassName = rowClassName(model);
    }
    options.className = rowClassName;

    var row = new Row(options);
    this.$('tbody').append(row.render(this.columns).el);
  },

  refresh: function(options) {
    if (this.options.paginated) {
      this._page(options);
    } else {
      if (this.options.inMemory) {
        this.collection.trigger('reset', this.collection);
        if (options && options.success) {
          options.success();
        }
      } else {
        this._request(options);
      }
    }
  },

  sort: function(column, order) {
    this.sorter.sort(column, order);
  },

  page: function(page) {
    this.pager.page(page);
  },

  perPage: function(perPage) {
    this.pager.set('perPage', perPage);
  },

  _sort: function() {
    if (this.options.inMemory) {
      this._sortInMemory();
    } else {
      this._sortRequest();
    }
  },

  _sortInMemory: function() {
    if (this.options.paginated) {
      this._originalCollection.comparator = _.bind(this._comparator, this);
      this._originalCollection.sort();
      this.page(1);
    } else {
      this.collection.comparator = _.bind(this._comparator, this);
      this.collection.sort();
    }
  },

  _comparator: function(model1, model2) {
    var columnComparator = this._comparatorForColumn(this.sorter.get('column'));
    var order = columnComparator(model1, model2);
    return this.sorter.sortedASC() ? order : -order;
  },

  _comparatorForColumn: function(column) {
    var c = _.find(this.columns, function(c) {
      return c.property === column || c.index === column;
    });
    return c ? c.comparator : undefined;
  },

  _sortRequest: function() {
    this._request();
  },

  _page: function(options) {
    if (this.options.inMemory) {
      this._pageInMemory(options);
    } else {
      this._pageRequest(options);
    }
  },

  _pageRequest: function(options) {
    this._request(options);
  },

  _request: function(options) {
    options     = options || {};
    var success = options.success;
    var silent  = options.silent;

    options.data = this._getRequestData();
    options.success = _.bind(function(collection) {
      if (!this.columns || _.isEmpty(this.columns)) {
        this._prepareColumns();
      }
      if (success) {
        success();
      }
      if (this.options.paginated) {
        this.pager.update(collection);
      }
      if (!silent) {
        collection.trigger('reset', collection);
      }
    }, this);
    options.silent = true;

    this.collection.fetch(options);
  },

  _getRequestData: function() {
    if (this.collection.data && _.isFunction(this.collection.data)) {
      return this.collection.data(this.pager, this.sorter);
    } else if (this.collection.data && typeof this.collection.data === 'object') {
      var data = {};
      _.each(this.collection.data, function(value, param) {
        if (_.isFunction(value)) {
          value = value(this.pager, this.sorter);
        }
        data[param] = value;
      }, this);
      return data;
    } else if (this.options.paginated) {
      return {
        page:     this.pager.get('currentPage'),
        per_page: this.pager.get('perPage')
      };
    }

    return {};
  },

  _pageInMemory: function(options) {
    if (!this._originalCollection) {
      this._originalCollection = this.collection.clone();
    }

    var page    = this.pager.get('currentPage');
    var perPage = this.pager.get('perPage');

    var begin = (page - 1) * perPage;
    var end   = begin + perPage;

    if (options && options.success) {
      options.success();
    }
    this.pager.set('total', this._originalCollection.size());

    this.collection.reset(this._originalCollection.slice(begin, end), options);
  },

  _prepare: function() {
    this._prepareSorter();
    this._preparePager();
    this._prepareColumns();
    this.refresh();
  },

  _prepareSorter: function() {
    this.sorter = new Sorter();
    this.sorter.on('change', function() {
      this._sort(this.sorter.get('column'), this.sorter.get('order'));
    }, this);
  },

  _preparePager: function() {
    this.pager = new Pager({
      currentPage: this.options.page,
      perPage:     this.options.perPage
    });

    this.pager.on('change:currentPage', function () {
      this._page();
    }, this);
    this.pager.on('change:perPage', function() {
      this.page(1);
    }, this);
  },

  _prepareColumns: function() {
    if (!this.columns || _.isEmpty(this.columns)) {
      this._defaultColumns();
    } else {
      _.each(this.columns, function(column, i) {
        this.columns[i] = this._prepareColumn(column, i);
      }, this);
    }
  },

  _prepareColumn: function(column, index) {
    if (_.isString(column)) {
      column = { property: column };
    }
    if (_.isObject(column)) {
      column.index = index;
      if (column.property) {
        column.title = column.title || this._formatTitle(column.property);
      } else if (!column.property && !column.view) {
        throw new Error('Column \'' + column.title + '\' has no property and must accordingly define a custom cell view.');
      }
      if (this.options.inMemory && column.sortable) {
        if (!column.comparator && !column.property && !column.sortedProperty) {
          throw new Error('Invalid column definition: a sortable column must have a comparator, property or sortedProperty defined.');
        }
        column.comparator = column.comparator || this._defaultComparator(column.sortedProperty || column.property);
      }
    }
    return column;
  },

  _formatTitle: function(title) {
    return _.map(title.split(/\s|_/), function(word) {
      return word.charAt(0).toUpperCase() + word.substr(1);
    }).join(' ');
  },

  _defaultColumns: function() {
    this.columns = [];
    var model = this.collection.first(), i = 0;
    if (model) {
      for (var p in model.toJSON()) {
        this.columns.push(this._prepareColumn(p, i++));
      }
    }
  },

  _defaultComparator: function(column) {
    return function(model1, model2) {
      var val1 = model1.has(column) ? model1.get(column) : '';
      var val2 = model2.has(column) ? model2.get(column) : '';
      return val1.localeCompare(val2);
    };
  }
});

var Header = Datagrid.Header = Backbone.View.extend({
  tagName: 'thead',

  initialize: function() {
    this.columns = this.options.columns;
    this.sorter  = this.options.sorter;
  },

  render: function() {
    var model = new Backbone.Model();
    var headerColumn, columns = [];
    _.each(this.columns, function(column, i) {
      headerColumn          = _.clone(column);
      headerColumn.property = column.property || column.index;
      headerColumn.view     = column.headerView || {
          type: HeaderCell,
          sorter: this.sorter
        };

      model.set(headerColumn.property, column.title);
      columns.push(headerColumn);
    }, this);

    var row = new Row({model: model, columns: columns, header: true});
    this.$el.html(row.render().el);

    return this;
  }
});

var Row = Datagrid.Row = Backbone.View.extend({
  tagName: 'tr',

  initialize: function() {
    this.columns = this.options.columns;
    this.model.on('change', this.render, this);
  },

  render: function() {
    this.$el.empty();
    _.each(this.columns, this.renderCell, this);
    return this;
  },

  renderCell: function(column) {
    var cellView = this._resolveCellView(column);
    this.$el.append(cellView.render().el);
  },

  _resolveCellView: function(column) {
    var options = {
      model:  this.model,
      column: column
    };
    if (this.options.header || column.header) {
      options.tagName = 'th';
    }
    var cellClassName = column.cellClassName;
    if (_.isFunction(cellClassName)) {
      cellClassName = cellClassName(this.model);
    }
    options.className = cellClassName;


    var view = column.view || Cell;

    // Resolve view from string or function
    if (typeof view !== 'object' && !(view.prototype && view.prototype.render)) {
      if (_.isString(view)) {
        options.callback = _.template(view);
        view = CallbackCell;
      } else if (_.isFunction(view) && !view.prototype.render) {
        options.callback = view;
        view = CallbackCell;
      } else {
        throw new TypeError('Invalid view passed to column "' + column.title + '".');
      }
    }

    // Resolve view from options
    else if (typeof view === 'object') {
      _.extend(options, view);
      view = view.type;
      if (!view || !view.prototype || !view.prototype.render) {
        throw new TypeError('Invalid view passed to column "' + column.title + '".');
      }
    }

    return new view(options);
  }
});

var Pagination = Datagrid.Pagination = Backbone.View.extend({
  className: 'pagination pagination-centered',

  events: {
    'click li:not(.disabled) a': 'page',
    'click li.disabled a': function(e) { e.preventDefault(); }
  },

  initialize: function() {
    this.pager = this.options.pager;
  },

  render: function() {
    var $ul = $('<ul></ul>'), $li;

    $li = $('<li class="prev"><a href="#">«</a></li>');
    if (!this.pager.hasPrev()) {
      $li.addClass('disabled');
    }
    $ul.append($li);

    if (this.pager.hasTotal()) {
      for (var i = 1; i <= this.pager.get('totalPages'); i++) {
        $li = $('<li></li>');
        if (i === this.pager.get('currentPage')) {
          $li.addClass('active');
        }
        $li.append('<a href="#">' + i + '</a>');
        $ul.append($li);
      }
    }

    $li = $('<li class="next"><a href="#">»</a></li>');
    if (!this.pager.hasNext()) {
      $li.addClass('disabled');
    }
    $ul.append($li);

    this.$el.append($ul);
    return this;
  },

  page: function(event) {
    var $target = $(event.target), page;
    if ($target.parent().hasClass('prev')) {
      this.pager.prev();
    } else if ($target.parent().hasClass('next')) {
      this.pager.next();
    }
    else {
      this.pager.page(parseInt($(event.target).html(), 10));
    }
    return false;
  }
});

var Cell = Datagrid.Cell = Backbone.View.extend({
  tagName: 'td',

  initialize: function() {
    this.column = this.options.column;
  },

  render: function() {
    this._prepareValue();
    this.$el.html(this.value);
    return this;
  },

  _prepareValue: function() {
    this.value = this.model.get(this.column.property);

    if (this.value && this.value.length > 32) {
      this.value = "<div>" + this.value + "</div>";
    }
  }
});

var CallbackCell = Datagrid.CallbackCell = Cell.extend({
  initialize: function() {
    CallbackCell.__super__.initialize.call(this);
    this.callback = this.options.callback;
  },

  _prepareValue: function() {
    this.value = this.callback(this.model.toJSON());
  }
});

var ActionCell = Datagrid.ActionCell = Cell.extend({
  initialize: function() {
    ActionCell.__super__.initialize.call(this);
  },

  action: function() {
    return this.options.action(this.model);
  },

  _prepareValue: function() {
    var a = $('<a></a>');

    a.html(this.options.label);
    a.attr('href', this.options.href || '#');
    if (this.options.actionClassName) {
      a.addClass(this.options.actionClassName);
    }
    if (this.options.action) {
      this.delegateEvents({
        'click a': this.action
      });
    }

    this.value = a;
  }
});

var HeaderCell = Datagrid.HeaderCell = Cell.extend({
  initialize: function() {
    HeaderCell.__super__.initialize.call(this);

    this.sorter = this.options.sorter;

    if (this.column.sortable) {
      this.delegateEvents({click: 'sort'});
    }
  },

  render: function() {
    this._prepareValue();
    var html = this.value, icon;

    if (this.column.sortable) {
      this.$el.addClass('sortable');
      if (this.sorter.sortedBy(this.column.sortedProperty || this.column.property) || this.sorter.sortedBy(this.column.index)) {
        if (this.sorter.sortedASC()) {
          icon = 'icon-chevron-up';
        } else {
          icon = 'icon-chevron-down';
        }
      } else {
        icon = 'icon-minus';
      }

      html += ' <i class="' + icon + ' pull-right"></i>';
    }

    this.$el.html(html);
    return this;
  },

  sort: function() {
    this.sorter.sort(this.column.sortedProperty || this.column.property);
  }
});

var Pager = Datagrid.Pager = Backbone.Model.extend({
  initialize: function() {
    this.on('change:perPage change:total', function() {
      this.totalPages(this.get('total'));
    }, this);
    if (this.has('total')) {
      this.totalPages(this.get('total'));
    }
  },

  update: function(options) {
    _.each(['hasNext', 'hasPrev', 'total', 'totalPages', 'lastPage'], function(p) {
      if (!_.isUndefined(options[p])) {
        this.set(p, options[p]);
      }
    }, this);
  },

  totalPages: function(total) {
    if (_.isNumber(total)) {
      this.set('totalPages', Math.ceil(total/this.get('perPage')));
    } else {
      this.set('totalPages', undefined);
    }
  },

  page: function(page) {
    if (this.inBounds(page)) {
      if (page === this.get('currentPage')) {
        this.trigger('change:currentPage');
      } else {
        this.set('currentPage', page);
      }
    }
  },

  next: function() {
    this.page(this.get('currentPage') + 1);
  },

  prev: function() {
    this.page(this.get('currentPage') - 1);
  },

  hasTotal: function() {
    return this.has('totalPages');
  },

  hasNext: function() {
    if (this.hasTotal()) {
      return this.get('currentPage') < this.get('totalPages');
    } else {
      return this.get('hasNext');
    }
  },

  hasPrev: function() {
    if (this.has('hasPrev')) {
      return this.get('hasPrev');
    } else {
      return this.get('currentPage') > 1;
    }
  },

  inBounds: function(page) {
    return !this.hasTotal() || page > 0 && page <= this.get('totalPages');
  },

  set: function() {
    var args = [];
    for (var i = 0; i < arguments.length; i++) {
      args.push(arguments[i]);
    }
    args[2] = _.extend({}, args[2], {validate: true});
    Backbone.Model.prototype.set.apply(this, args);
  },

  validate: function(attrs) {
    if (attrs.perPage < 1) {
      throw new Error('perPage must be greater than zero.');
    }
  }
});

var Sorter = Datagrid.Sorter = Backbone.Model.extend({
  sort: function(column, order) {
    if (!order && this.get('column') === column) {
      this.toggleOrder();
    } else {
      this.set({
        column: column,
        order: order || Sorter.ASC
      });
    }
  },

  sortedBy: function(column) {
    return this.get('column') === column;
  },

  sortedASC: function() {
    return this.get('order') === Sorter.ASC;
  },

  sortedDESC: function() {
    return this.get('order') === Sorter.DESC;
  },

  toggleOrder: function() {
    if (this.get('order') === Sorter.ASC) {
      this.set('order', Sorter.DESC);
    } else {
      this.set('order', Sorter.ASC);
    }
  }
});

Sorter.ASC  = 'asc';
Sorter.DESC = 'desc';

  Backbone.Datagrid = Datagrid;
})();