/*

 @author Rowan Crawford (wombleton@gmail.com)
 @version 0.3
 @requires jQuery, $.uritemplate
 @link http://github.com/wombleton/linkheaders

 JavaScript parsing of linkheaders as per http://tools.ietf.org/html/draft-nottingham-http-link-header-10

 Usage:
 var linkHeader = '</collection/{itemId}>; rel="foo foz bar"; type="application/json", </fozzes/{fozId}>; rel="foz baz"; type="application/json"';
 var links = $.linkheaders(linkHeader);
 links.find('foo bar').href().expand({ itemId: 'xxx' }) => /collection/xxx
 links.find(['foz']).href().expand({ itemId: 'xxx' }) => /collection/xxx
 links.find('baz').rel() => 'foz baz'
 links.find('foz').attr('type') => 'application/json
 links.findAll('foz') => Array with two links
 links.each(fn) => calls fn(i, link) on each link.
 links.each('foo', fn) => calls fn(i, link) on each link that has rel 'foo'.

 MIT License

*/

(function($, undefined) {
  // taken from linkheader.grammer.min.js
  // regenerate by using linkheaders.pegjs in http://pegjs.majda.cz
  var parser=(function(){var a={parse:function(k){var h=0;var p=0;var g=[];var n={};function s(z,D,B){var y=z;var C=B-z.length;for(var A=0;A<C;A++){y=D+y}return y}function q(A){var z=A.charCodeAt(0);if(z<=255){var y="x";var B=2}else{var y="u";var B=4}return"\\"+y+s(z.toString(16).toUpperCase(),"0",B)}function t(y){return'"'+y.replace(/\\/g,"\\\\").replace(/"/g,'\\"').replace(/\r/g,"\\r").replace(/\u2028/g,"\\u2028").replace(/\u2029/g,"\\u2029").replace(/\n/g,"\\n").replace(/[\x80-\uFFFF]/g,q)+'"'}function w(B,A){var z=B.length;for(var y=0;y<z;y++){if(B[y]===A){return true}}return false}function l(y){if(h<p){return}if(h>p){p=h;g=[]}if(!w(g,y)){g.push(y)}}function c(B){var D="links@"+h;var A=n[D];if(A){h=A.nextPos;return A.result}var y=v(B);if(y!==null){var z=[];while(y!==null){z.push(y);var y=v(B)}}else{var z=null}var C=z!==null?(function(F){var E=[],G;for(G=0;G<F.length;G++){E.push(F[G])}return E})(z):null;n[D]={nextPos:h,result:C};return C}function v(B){var I="link@"+h;var C=n[I];if(C){h=C.nextPos;return C.result}var J=h;var F=d(B);if(F!==null){var E=u(B);if(E!==null){var D=e(B);if(D!==null){if(k.substr(h,1)===","){var y=",";h+=1}else{var y=null;if(B.reportMatchFailures){l(t(","))}}var A=y!==null?y:"";if(A!==null){var z=u(B);if(z!==null){var G=[F,E,D,A,z]}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}var H=G!==null?(function(L,K){var M=K;M.href=L;return M})(G[0],G[2]):null;n[I]={nextPos:h,result:H};return H}function d(y){var G="href@"+h;var A=n[G];if(A){h=A.nextPos;return A.result}var H=h;if(k.substr(h,1)==="<"){var D="<";h+=1}else{var D=null;if(y.reportMatchFailures){l(t("<"))}}if(D!==null){var C=f(y);if(C!==null){if(k.substr(h,1)===">"){var B=">";h+=1}else{var B=null;if(y.reportMatchFailures){l(t(">"))}}if(B!==null){if(k.substr(h,1)===";"){var z=";";h+=1}else{var z=null;if(y.reportMatchFailures){l(t(";"))}}if(z!==null){var E=[D,C,B,z]}else{var E=null;h=H}}else{var E=null;h=H}}else{var E=null;h=H}}else{var E=null;h=H}var F=E!==null?(function(I){return I})(E[1]):null;n[G]={nextPos:h,result:F};return F}function e(B){var D="attributes@"+h;var A=n[D];if(A){h=A.nextPos;return A.result}var y=m(B);if(y!==null){var z=[];while(y!==null){z.push(y);var y=m(B)}}else{var z=null}var C=z!==null?(function(E){var G={},F;for(F=0;F<E.length;F++){G[E[F].name]=E[F].value}return G})(z):null;n[D]={nextPos:h,result:C};return C}function m(A){var I="attribute@"+h;var C=n[I];if(C){h=C.nextPos;return C.result}var J=h;var F=i(A);if(F!==null){var E=u(A);if(E!==null){if(k.substr(h,1)==="="){var D="=";h+=1}else{var D=null;if(A.reportMatchFailures){l(t("="))}}if(D!==null){var B=u(A);if(B!==null){var z=r(A);if(z!==null){if(k.substr(h,1)===";"){var K=";";h+=1}else{var K=null;if(A.reportMatchFailures){l(t(";"))}}var y=K!==null?K:"";if(y!==null){var L=u(A);if(L!==null){var G=[F,E,D,B,z,y,L]}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}}else{var G=null;h=J}var H=G!==null?(function(N,M){return{name:N,value:M}})(G[0],G[4]):null;n[I]={nextPos:h,result:H};return H}function i(B){var D="name@"+h;var A=n[D];if(A){h=A.nextPos;return A.result}if(k.substr(h).match(/^[a-zA-Z]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(B.reportMatchFailures){l("[a-zA-Z]")}}if(y!==null){var z=[];while(y!==null){z.push(y);if(k.substr(h).match(/^[a-zA-Z]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(B.reportMatchFailures){l("[a-zA-Z]")}}}}else{var z=null}var C=z!==null?(function(E){return E.join("")})(z):null;n[D]={nextPos:h,result:C};return C}function r(B){var I="value@"+h;var D=n[I];if(D){h=D.nextPos;return D.result}var J=h;if(k.substr(h).match(/^["]/)!==null){var z=k.charAt(h);h++}else{var z=null;if(B.reportMatchFailures){l('["]')}}if(z!==null){if(k.substr(h).match(/^[^"]/)!==null){var K=k.charAt(h);h++}else{var K=null;if(B.reportMatchFailures){l('[^"]')}}if(K!==null){var y=[];while(K!==null){y.push(K);if(k.substr(h).match(/^[^"]/)!==null){var K=k.charAt(h);h++}else{var K=null;if(B.reportMatchFailures){l('[^"]')}}}}else{var y=null}if(y!==null){if(k.substr(h).match(/^["]/)!==null){var L=k.charAt(h);h++}else{var L=null;if(B.reportMatchFailures){l('["]')}}if(L!==null){var A=[z,y,L]}else{var A=null;h=J}}else{var A=null;h=J}}else{var A=null;h=J}var C=A!==null?(function(M){return M.join("")})(A[1]):null;if(C!==null){var H=C}else{if(k.substr(h).match(/^[^";,]/)!==null){var E=k.charAt(h);h++}else{var E=null;if(B.reportMatchFailures){l('[^";,]')}}if(E!==null){var F=[];while(E!==null){F.push(E);if(k.substr(h).match(/^[^";,]/)!==null){var E=k.charAt(h);h++}else{var E=null;if(B.reportMatchFailures){l('[^";,]')}}}}else{var F=null}var G=F!==null?(function(M){return M.join("")})(F):null;if(G!==null){var H=G}else{var H=null}}n[I]={nextPos:h,result:H};return H}function f(B){var D="url@"+h;var A=n[D];if(A){h=A.nextPos;return A.result}if(k.substr(h).match(/^[^>]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(B.reportMatchFailures){l("[^>]")}}if(y!==null){var z=[];while(y!==null){z.push(y);if(k.substr(h).match(/^[^>]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(B.reportMatchFailures){l("[^>]")}}}}else{var z=null}var C=z!==null?(function(E){return E.join("")})(z):null;n[D]={nextPos:h,result:C};return C}function u(A){var C="ws@"+h;var z=n[C];if(z){h=z.nextPos;return z.result}var B=[];if(k.substr(h).match(/^[ ]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(A.reportMatchFailures){l("[ ]")}}while(y!==null){B.push(y);if(k.substr(h).match(/^[ ]/)!==null){var y=k.charAt(h);h++}else{var y=null;if(A.reportMatchFailures){l("[ ]")}}}n[C]={nextPos:h,result:B};return B}function b(){function A(C){switch(C.length){case 0:return"end of input";case 1:return C[0];default:C.sort();return C.slice(0,C.length-1).join(", ")+" or "+C[C.length-1]}}var z=A(g);var y=Math.max(h,p);var B=y<k.length?t(k.charAt(y)):"end of input";return"Expected "+z+" but "+B+" found."}function x(){var y=1;var B=1;var C=false;for(var z=0;z<p;z++){var A=k.charAt(z);if(A==="\n"){if(!C){y++}B=1;C=false}else{if(A==="\r"|A==="\u2028"||A==="\u2029"){y++;B=1;C=true}else{B++;C=false}}}return{line:y,column:B}}var j=c({reportMatchFailures:true});if(j===null||h!==k.length){var o=x();throw new this.SyntaxError(b(),o.line,o.column)}return j},toSource:function(){return this._source}};a.SyntaxError=function(d,b,c){this.name="SyntaxError";this.message=d;this.line=b;this.column=c};a.SyntaxError.prototype=Error.prototype;return a})();

  function Link(attrs) {
    var href,
        rels = [];

    href = attrs.href;
    rels = (attrs.rel || '').split(' ');

    return {
      attr: function(key) {
        return attrs[key] || '';
      },
      resolve: function(obj) {
        return this.template().expand(obj);
      },
      template: function() {
        return $.uritemplate(href);
      },
      rels: function() {
        return rels;
      },
      match: function(matches) {
        matches = $.isArray(matches) ? matches : matches.split(' ');

        for (var i = 0; i < matches.length; i++) {
          var match = matches[i];
          if ($.inArray(match, rels) < 0) {
            return false;
          }
        }
        return true;
      }
    }
  }

  function Links(header) {
    var i,
        parsed,
        links = [];

    try {
      parsed = parser.parse(header);
    } catch(e) { /* do nothing */ }

    for (i = 0; parsed && i < parsed.length; i++) {
      links.push(new Link(parsed[i]));
    }

    function find(rels) {
      var links = findAll(rels);
      return links.length ? links[0] : null;
    }

    function findAll(rels) {
      var i,
          link,
          result = [];

      for (i = 0; i < links.length; i++) {
        link = links[i];
        if (!rels || link.match(rels)) {
          result.push(link);
        }
      }
      return result;
    }

    return {
      each: function(rels, fn) {
        if ($.isFunction(rels)) {
          fn = rels;
          rels = undefined;
        }
        $.each(findAll(rels), fn);
      },
      find: find,
      findAll: findAll
    }
  }

  function linkheaders(header) {
    return new Links(header);
  }

  $.extend({
    linkheaders: linkheaders
  })

})(jQuery);