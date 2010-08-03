var BiwaScheme = BiwaScheme || {};
BiwaScheme.Version = "0.5.3.3";
BiwaScheme.GitCommit = "9e6f14d804211a0cf4ca825251e03b3ae78fcfd5";
BiwaScheme.require = function (f, c, a) {
    var d = document.createElement("script");
    d.src = f;
    document.body.appendChild(d);
    var e = new Function("return !!(" + c + ")");
    if (e()) {
        a()
    } else {
        setTimeout(function () {
            e() ? a() : setTimeout(arguments.callee, 10)
        }, 10)
    }
};
Console = {};
Console.puts = function (d, a) {
    var c = (d + (a ? "" : "\n")).escapeHTML();
    span = document.createElement("span");
    span.innerHTML = c.replace(/\n/g, "<br>").replace(/ /g, "&nbsp;");
    $("bs-console").insert(span)
};
Console.p = function () {
    Console.puts("p> " + $A(arguments).map(Object.inspect).join(" "))
};
var Prototype = {
    Version: "1.6.0.3",
    Browser: {
        IE: !! (window.attachEvent && navigator.userAgent.indexOf("Opera") === -1),
        Opera: navigator.userAgent.indexOf("Opera") > -1,
        WebKit: navigator.userAgent.indexOf("AppleWebKit/") > -1,
        Gecko: navigator.userAgent.indexOf("Gecko") > -1 && navigator.userAgent.indexOf("KHTML") === -1,
        MobileSafari: !! navigator.userAgent.match(/Apple.*Mobile.*Safari/)
    },
    BrowserFeatures: {
        XPath: !! document.evaluate,
        SelectorsAPI: !! document.querySelector,
        ElementExtensions: !! window.HTMLElement,
        SpecificElementExtensions: document.createElement("div")["__proto__"] && document.createElement("div")["__proto__"] !== document.createElement("form")["__proto__"]
    },
    ScriptFragment: "<script[^>]*>([\\S\\s]*?)<\/script>",
    JSONFilter: /^\/\*-secure-([\s\S]*)\*\/\s*$/,
    emptyFunction: function () {},
    K: function (a) {
        return a
    }
};
if (Prototype.Browser.MobileSafari) {
    Prototype.BrowserFeatures.SpecificElementExtensions = false
}
var Class = {
    create: function () {
        var f = null,
            e = $A(arguments);
        if (Object.isFunction(e[0])) {
            f = e.shift()
        }
        function a() {
            this.initialize.apply(this, arguments)
        }
        Object.extend(a, Class.Methods);
        a.superclass = f;
        a.subclasses = [];
        if (f) {
            var c = function () {};
            c.prototype = f.prototype;
            a.prototype = new c;
            f.subclasses.push(a)
        }
        for (var d = 0; d < e.length; d++) {
            a.addMethods(e[d])
        }
        if (!a.prototype.initialize) {
            a.prototype.initialize = Prototype.emptyFunction
        }
        a.prototype.constructor = a;
        return a
    }
};
Class.Methods = {
    addMethods: function (h) {
        var d = this.superclass && this.superclass.prototype;
        var c = Object.keys(h);
        if (!Object.keys({
            toString: true
        }).length) {
            c.push("toString", "valueOf")
        }
        for (var a = 0, e = c.length; a < e; a++) {
            var g = c[a],
                f = h[g];
            if (d && Object.isFunction(f) && f.argumentNames().first() == "$super") {
                var j = f;
                f = (function (k) {
                    return function () {
                        return d[k].apply(this, arguments)
                    }
                })(g).wrap(j);
                f.valueOf = j.valueOf.bind(j);
                f.toString = j.toString.bind(j)
            }
            this.prototype[g] = f
        }
        return this
    }
};
var Abstract = {};
Object.extend = function (a, d) {
    for (var c in d) {
        a[c] = d[c]
    }
    return a
};
Object.extend(Object, {
    inspect: function (a) {
        try {
            if (Object.isUndefined(a)) {
                return "undefined"
            }
            if (a === null) {
                return "null"
            }
            return a.inspect ? a.inspect() : String(a)
        } catch (c) {
            if (c instanceof RangeError) {
                return "..."
            }
            throw c
        }
    },
    toJSON: function (a) {
        var d = typeof a;
        switch (d) {
        case "undefined":
        case "function":
        case "unknown":
            return;
        case "boolean":
            return a.toString()
        }
        if (a === null) {
            return "null"
        }
        if (a.toJSON) {
            return a.toJSON()
        }
        if (Object.isElement(a)) {
            return
        }
        var c = [];
        for (var f in a) {
            var e = Object.toJSON(a[f]);
            if (!Object.isUndefined(e)) {
                c.push(f.toJSON() + ": " + e)
            }
        }
        return "{" + c.join(", ") + "}"
    },
    toQueryString: function (a) {
        return $H(a).toQueryString()
    },
    toHTML: function (a) {
        return a && a.toHTML ? a.toHTML() : String.interpret(a)
    },
    keys: function (a) {
        var c = [];
        for (var d in a) {
            c.push(d)
        }
        return c
    },
    values: function (c) {
        var a = [];
        for (var d in c) {
            a.push(c[d])
        }
        return a
    },
    clone: function (a) {
        return Object.extend({}, a)
    },
    isElement: function (a) {
        return !!(a && a.nodeType == 1)
    },
    isArray: function (a) {
        return a != null && typeof a == "object" && "splice" in a && "join" in a
    },
    isHash: function (a) {
        return a instanceof Hash
    },
    isFunction: function (a) {
        return typeof a == "function"
    },
    isString: function (a) {
        return typeof a == "string"
    },
    isNumber: function (a) {
        return typeof a == "number"
    },
    isUndefined: function (a) {
        return typeof a == "undefined"
    }
});
Object.extend(Function.prototype, {
    argumentNames: function () {
        var a = this.toString().match(/^[\s\(]*function[^(]*\(([^\)]*)\)/)[1].replace(/\s+/g, "").split(",");
        return a.length == 1 && !a[0] ? [] : a
    },
    bind: function () {
        if (arguments.length < 2 && Object.isUndefined(arguments[0])) {
            return this
        }
        var a = this,
            d = $A(arguments),
            c = d.shift();
        return function () {
            return a.apply(c, d.concat($A(arguments)))
        }
    },
    bindAsEventListener: function () {
        var a = this,
            d = $A(arguments),
            c = d.shift();
        return function (e) {
            return a.apply(c, [e || window.event].concat(d))
        }
    },
    curry: function () {
        if (!arguments.length) {
            return this
        }
        var a = this,
            c = $A(arguments);
        return function () {
            return a.apply(this, c.concat($A(arguments)))
        }
    },
    delay: function () {
        var a = this,
            c = $A(arguments),
            d = c.shift() * 1000;
        return window.setTimeout(function () {
            return a.apply(a, c)
        }, d)
    },
    defer: function () {
        var a = [0.01].concat($A(arguments));
        return this.delay.apply(this, a)
    },
    wrap: function (c) {
        var a = this;
        return function () {
            return c.apply(this, [a.bind(this)].concat($A(arguments)))
        }
    },
    methodize: function () {
        if (this._methodized) {
            return this._methodized
        }
        var a = this;
        return this._methodized = function () {
            return a.apply(null, [this].concat($A(arguments)))
        }
    }
});
Date.prototype.toJSON = function () {
    return '"' + this.getUTCFullYear() + "-" + (this.getUTCMonth() + 1).toPaddedString(2) + "-" + this.getUTCDate().toPaddedString(2) + "T" + this.getUTCHours().toPaddedString(2) + ":" + this.getUTCMinutes().toPaddedString(2) + ":" + this.getUTCSeconds().toPaddedString(2) + 'Z"'
};
var Try = {
    these: function () {
        var d;
        for (var c = 0, f = arguments.length; c < f; c++) {
            var a = arguments[c];
            try {
                d = a();
                break
            } catch (g) {}
        }
        return d
    }
};
RegExp.prototype.match = RegExp.prototype.test;
RegExp.escape = function (a) {
    return String(a).replace(/([.*+?^=!:${}()|[\]\/\\])/g, "\\$1")
};
var PeriodicalExecuter = Class.create({
    initialize: function (c, a) {
        this.callback = c;
        this.frequency = a;
        this.currentlyExecuting = false;
        this.registerCallback()
    },
    registerCallback: function () {
        this.timer = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000)
    },
    execute: function () {
        this.callback(this)
    },
    stop: function () {
        if (!this.timer) {
            return
        }
        clearInterval(this.timer);
        this.timer = null
    },
    onTimerEvent: function () {
        if (!this.currentlyExecuting) {
            try {
                this.currentlyExecuting = true;
                this.execute()
            } finally {
                this.currentlyExecuting = false
            }
        }
    }
});
Object.extend(String, {
    interpret: function (a) {
        return a == null ? "" : String(a)
    },
    specialChar: {
        "\b": "\\b",
        "\t": "\\t",
        "\n": "\\n",
        "\f": "\\f",
        "\r": "\\r",
        "\\": "\\\\"
    }
});
Object.extend(String.prototype, {
    gsub: function (f, d) {
        var a = "",
            e = this,
            c;
        d = arguments.callee.prepareReplacement(d);
        while (e.length > 0) {
            if (c = e.match(f)) {
                a += e.slice(0, c.index);
                a += String.interpret(d(c));
                e = e.slice(c.index + c[0].length)
            } else {
                a += e, e = ""
            }
        }
        return a
    },
    sub: function (d, a, c) {
        a = this.gsub.prepareReplacement(a);
        c = Object.isUndefined(c) ? 1 : c;
        return this.gsub(d, function (e) {
            if (--c < 0) {
                return e[0]
            }
            return a(e)
        })
    },
    scan: function (c, a) {
        this.gsub(c, a);
        return String(this)
    },
    truncate: function (c, a) {
        c = c || 30;
        a = Object.isUndefined(a) ? "..." : a;
        return this.length > c ? this.slice(0, c - a.length) + a : String(this)
    },
    strip: function () {
        return this.replace(/^\s+/, "").replace(/\s+$/, "")
    },
    stripTags: function () {
        return this.replace(/<\/?[^>]+>/gi, "")
    },
    stripScripts: function () {
        return this.replace(new RegExp(Prototype.ScriptFragment, "img"), "")
    },
    extractScripts: function () {
        var c = new RegExp(Prototype.ScriptFragment, "img");
        var a = new RegExp(Prototype.ScriptFragment, "im");
        return (this.match(c) || []).map(function (d) {
            return (d.match(a) || ["", ""])[1]
        })
    },
    evalScripts: function () {
        return this.extractScripts().map(function (script) {
            return eval(script)
        })
    },
    escapeHTML: function () {
        var a = arguments.callee;
        a.text.data = this;
        return a.div.innerHTML
    },
    unescapeHTML: function () {
        var a = new Element("div");
        a.innerHTML = this.stripTags();
        return a.childNodes[0] ? (a.childNodes.length > 1 ? $A(a.childNodes).inject("", function (c, d) {
            return c + d.nodeValue
        }) : a.childNodes[0].nodeValue) : ""
    },
    toQueryParams: function (c) {
        var a = this.strip().match(/([^?#]*)(#.*)?$/);
        if (!a) {
            return {}
        }
        return a[1].split(c || "&").inject({}, function (f, g) {
            if ((g = g.split("="))[0]) {
                var d = decodeURIComponent(g.shift());
                var e = g.length > 1 ? g.join("=") : g[0];
                if (e != undefined) {
                    e = decodeURIComponent(e)
                }
                if (d in f) {
                    if (!Object.isArray(f[d])) {
                        f[d] = [f[d]]
                    }
                    f[d].push(e)
                } else {
                    f[d] = e
                }
            }
            return f
        })
    },
    toArray: function () {
        return this.split("")
    },
    succ: function () {
        return this.slice(0, this.length - 1) + String.fromCharCode(this.charCodeAt(this.length - 1) + 1)
    },
    times: function (a) {
        return a < 1 ? "" : new Array(a + 1).join(this)
    },
    camelize: function () {
        var e = this.split("-"),
            a = e.length;
        if (a == 1) {
            return e[0]
        }
        var d = this.charAt(0) == "-" ? e[0].charAt(0).toUpperCase() + e[0].substring(1) : e[0];
        for (var c = 1; c < a; c++) {
            d += e[c].charAt(0).toUpperCase() + e[c].substring(1)
        }
        return d
    },
    capitalize: function () {
        return this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()
    },
    underscore: function () {
        return this.gsub(/::/, "/").gsub(/([A-Z]+)([A-Z][a-z])/, "#{1}_#{2}").gsub(/([a-z\d])([A-Z])/, "#{1}_#{2}").gsub(/-/, "_").toLowerCase()
    },
    dasherize: function () {
        return this.gsub(/_/, "-")
    },
    inspect: function (c) {
        var a = this.gsub(/[\x00-\x1f\\]/, function (d) {
            var e = String.specialChar[d[0]];
            return e ? e : "\\u00" + d[0].charCodeAt().toPaddedString(2, 16)
        });
        if (c) {
            return '"' + a.replace(/"/g, '\\"') + '"'
        }
        return "'" + a.replace(/'/g, "\\'") + "'"
    },
    toJSON: function () {
        return this.inspect(true)
    },
    unfilterJSON: function (a) {
        return this.sub(a || Prototype.JSONFilter, "#{1}")
    },
    isJSON: function () {
        var a = this;
        if (a.blank()) {
            return false
        }
        a = this.replace(/\\./g, "@").replace(/"[^"\\\n\r]*"/g, "");
        return (/^[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]*$/).test(a)
    },
    evalJSON: function (sanitize) {
        var json = this.unfilterJSON();
        try {
            if (!sanitize || json.isJSON()) {
                return eval("(" + json + ")")
            }
        } catch (e) {}
        throw new SyntaxError("Badly formed JSON string: " + this.inspect())
    },
    include: function (a) {
        return this.indexOf(a) > -1
    },
    startsWith: function (a) {
        return this.indexOf(a) === 0
    },
    endsWith: function (a) {
        var c = this.length - a.length;
        return c >= 0 && this.lastIndexOf(a) === c
    },
    empty: function () {
        return this == ""
    },
    blank: function () {
        return /^\s*$/.test(this)
    },
    interpolate: function (a, c) {
        return new Template(this, c).evaluate(a)
    }
});
if (Prototype.Browser.WebKit || Prototype.Browser.IE) {
    Object.extend(String.prototype, {
        escapeHTML: function () {
            return this.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        },
        unescapeHTML: function () {
            return this.stripTags().replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
        }
    })
}
String.prototype.gsub.prepareReplacement = function (c) {
    if (Object.isFunction(c)) {
        return c
    }
    var a = new Template(c);
    return function (d) {
        return a.evaluate(d)
    }
};
String.prototype.parseQuery = String.prototype.toQueryParams;
Object.extend(String.prototype.escapeHTML, {
    div: document.createElement("div"),
    text: document.createTextNode("")
});
String.prototype.escapeHTML.div.appendChild(String.prototype.escapeHTML.text);
var Template = Class.create({
    initialize: function (a, c) {
        this.template = a.toString();
        this.pattern = c || Template.Pattern
    },
    evaluate: function (a) {
        if (Object.isFunction(a.toTemplateReplacements)) {
            a = a.toTemplateReplacements()
        }
        return this.template.gsub(this.pattern, function (e) {
            if (a == null) {
                return ""
            }
            var g = e[1] || "";
            if (g == "\\") {
                return e[2]
            }
            var c = a,
                h = e[3];
            var f = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
            e = f.exec(h);
            if (e == null) {
                return g
            }
            while (e != null) {
                var d = e[1].startsWith("[") ? e[2].gsub("\\\\]", "]") : e[1];c = c[d];
                if (null == c || "" == e[3]) {
                    break
                }
                h = h.substring("[" == e[3] ? e[1].length : e[0].length);e = f.exec(h)
            }
            return g + String.interpret(c)
        })
    }
});
Template.Pattern = /(^|.|\r|\n)(#\{(.*?)\})/;
var $break = {};
var Enumerable = {
    each: function (d, c) {
        var a = 0;
        try {
            this._each(function (e) {
                d.call(c, e, a++)
            })
        } catch (f) {
            if (f != $break) {
                throw f
            }
        }
        return this
    },
    eachSlice: function (e, d, c) {
        var a = -e,
            f = [],
            g = this.toArray();
        if (e < 1) {
            return g
        }
        while ((a += e) < g.length) {
            f.push(g.slice(a, a + e))
        }
        return f.collect(d, c)
    },
    all: function (d, c) {
        d = d || Prototype.K;
        var a = true;
        this.each(function (f, e) {
            a = a && !! d.call(c, f, e);
            if (!a) {
                throw $break
            }
        });
        return a
    },
    any: function (d, c) {
        d = d || Prototype.K;
        var a = false;
        this.each(function (f, e) {
            if (a = !! d.call(c, f, e)) {
                throw $break
            }
        });
        return a
    },
    collect: function (d, c) {
        d = d || Prototype.K;
        var a = [];
        this.each(function (f, e) {
            a.push(d.call(c, f, e))
        });
        return a
    },
    detect: function (d, c) {
        var a;
        this.each(function (f, e) {
            if (d.call(c, f, e)) {
                a = f;
                throw $break
            }
        });
        return a
    },
    findAll: function (d, c) {
        var a = [];
        this.each(function (f, e) {
            if (d.call(c, f, e)) {
                a.push(f)
            }
        });
        return a
    },
    grep: function (e, d, c) {
        d = d || Prototype.K;
        var a = [];
        if (Object.isString(e)) {
            e = new RegExp(e)
        }
        this.each(function (g, f) {
            if (e.match(g)) {
                a.push(d.call(c, g, f))
            }
        });
        return a
    },
    include: function (a) {
        if (Object.isFunction(this.indexOf)) {
            if (this.indexOf(a) != -1) {
                return true
            }
        }
        var c = false;
        this.each(function (d) {
            if (d == a) {
                c = true;
                throw $break
            }
        });
        return c
    },
    inGroupsOf: function (c, a) {
        a = Object.isUndefined(a) ? null : a;
        return this.eachSlice(c, function (d) {
            while (d.length < c) {
                d.push(a)
            }
            return d
        })
    },
    inject: function (a, d, c) {
        this.each(function (f, e) {
            a = d.call(c, a, f, e)
        });
        return a
    },
    invoke: function (c) {
        var a = $A(arguments).slice(1);
        return this.map(function (d) {
            return d[c].apply(d, a)
        })
    },
    max: function (d, c) {
        d = d || Prototype.K;
        var a;
        this.each(function (f, e) {
            f = d.call(c, f, e);
            if (a == null || f >= a) {
                a = f
            }
        });
        return a
    },
    min: function (d, c) {
        d = d || Prototype.K;
        var a;
        this.each(function (f, e) {
            f = d.call(c, f, e);
            if (a == null || f < a) {
                a = f
            }
        });
        return a
    },
    partition: function (e, c) {
        e = e || Prototype.K;
        var d = [],
            a = [];
        this.each(function (g, f) {
            (e.call(c, g, f) ? d : a).push(g)
        });
        return [d, a]
    },
    pluck: function (c) {
        var a = [];
        this.each(function (d) {
            a.push(d[c])
        });
        return a
    },
    reject: function (d, c) {
        var a = [];
        this.each(function (f, e) {
            if (!d.call(c, f, e)) {
                a.push(f)
            }
        });
        return a
    },
    sortBy: function (c, a) {
        return this.map(function (e, d) {
            return {
                value: e,
                criteria: c.call(a, e, d)
            }
        }).sort(function (g, f) {
            var e = g.criteria,
                d = f.criteria;
            return e < d ? -1 : e > d ? 1 : 0
        }).pluck("value")
    },
    toArray: function () {
        return this.map()
    },
    zip: function () {
        var c = Prototype.K,
            a = $A(arguments);
        if (Object.isFunction(a.last())) {
            c = a.pop()
        }
        var d = [this].concat(a).map($A);
        return this.map(function (f, e) {
            return c(d.pluck(e))
        })
    },
    size: function () {
        return this.toArray().length
    },
    inspect: function () {
        return "#<Enumerable:" + this.toArray().inspect() + ">"
    }
};
Object.extend(Enumerable, {
    map: Enumerable.collect,
    find: Enumerable.detect,
    select: Enumerable.findAll,
    filter: Enumerable.findAll,
    member: Enumerable.include,
    entries: Enumerable.toArray,
    every: Enumerable.all,
    some: Enumerable.any
});

function $A(d) {
    if (!d) {
        return []
    }
    if (d.toArray) {
        return d.toArray()
    }
    var c = d.length || 0,
        a = new Array(c);
    while (c--) {
        a[c] = d[c]
    }
    return a
}
if (Prototype.Browser.WebKit) {
    $A = function (d) {
        if (!d) {
            return []
        }
        if (!(typeof d === "function" && typeof d.length === "number" && typeof d.item === "function") && d.toArray) {
            return d.toArray()
        }
        var c = d.length || 0,
            a = new Array(c);
        while (c--) {
            a[c] = d[c]
        }
        return a
    }
}
Array.from = $A;
Object.extend(Array.prototype, Enumerable);
if (!Array.prototype._reverse) {
    Array.prototype._reverse = Array.prototype.reverse
}
Object.extend(Array.prototype, {
    _each: function (c) {
        for (var a = 0, d = this.length; a < d; a++) {
            c(this[a])
        }
    },
    clear: function () {
        this.length = 0;
        return this
    },
    first: function () {
        return this[0]
    },
    last: function () {
        return this[this.length - 1]
    },
    compact: function () {
        return this.select(function (a) {
            return a != null
        })
    },
    flatten: function () {
        return this.inject([], function (c, a) {
            return c.concat(Object.isArray(a) ? a.flatten() : [a])
        })
    },
    without: function () {
        var a = $A(arguments);
        return this.select(function (c) {
            return !a.include(c)
        })
    },
    reverse: function (a) {
        return (a !== false ? this : this.toArray())._reverse()
    },
    reduce: function () {
        return this.length > 1 ? this : this[0]
    },
    uniq: function (a) {
        return this.inject([], function (e, d, c) {
            if (0 == c || (a ? e.last() != d : !e.include(d))) {
                e.push(d)
            }
            return e
        })
    },
    intersect: function (a) {
        return this.uniq().findAll(function (c) {
            return a.detect(function (d) {
                return c === d
            })
        })
    },
    clone: function () {
        return [].concat(this)
    },
    size: function () {
        return this.length
    },
    inspect: function () {
        return "[" + this.map(Object.inspect).join(", ") + "]"
    },
    toJSON: function () {
        var a = [];
        this.each(function (c) {
            var d = Object.toJSON(c);
            if (!Object.isUndefined(d)) {
                a.push(d)
            }
        });
        return "[" + a.join(", ") + "]"
    }
});
if (Object.isFunction(Array.prototype.forEach)) {
    Array.prototype._each = Array.prototype.forEach
}
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (d, a) {
        a || (a = 0);
        var c = this.length;
        if (a < 0) {
            a = c + a
        }
        for (; a < c; a++) {
            if (this[a] === d) {
                return a
            }
        }
        return -1
    }
}
if (!Array.prototype.lastIndexOf) {
    Array.prototype.lastIndexOf = function (c, a) {
        a = isNaN(a) ? this.length : (a < 0 ? this.length + a : a) + 1;
        var d = this.slice(0, a).reverse().indexOf(c);
        return (d < 0) ? d : a - d - 1
    }
}
Array.prototype.toArray = Array.prototype.clone;

function $w(a) {
    if (!Object.isString(a)) {
        return []
    }
    a = a.strip();
    return a ? a.split(/\s+/) : []
}
if (Prototype.Browser.Opera) {
    Array.prototype.concat = function () {
        var f = [];
        for (var c = 0, d = this.length; c < d; c++) {
            f.push(this[c])
        }
        for (var c = 0, d = arguments.length; c < d; c++) {
            if (Object.isArray(arguments[c])) {
                for (var a = 0, e = arguments[c].length; a < e; a++) {
                    f.push(arguments[c][a])
                }
            } else {
                f.push(arguments[c])
            }
        }
        return f
    }
}
Object.extend(Number.prototype, {
    toColorPart: function () {
        return this.toPaddedString(2, 16)
    },
    succ: function () {
        return this + 1
    },
    times: function (c, a) {
        $R(0, this, true).each(c, a);
        return this
    },
    toPaddedString: function (d, c) {
        var a = this.toString(c || 10);
        return "0".times(d - a.length) + a
    },
    toJSON: function () {
        return isFinite(this) ? this.toString() : "null"
    }
});
$w("abs round ceil floor").each(function (a) {
    Number.prototype[a] = Math[a].methodize()
});

function $H(a) {
    return new Hash(a)
}
var Hash = Class.create(Enumerable, (function () {
    function a(c, d) {
        if (Object.isUndefined(d)) {
            return c
        }
        return c + "=" + encodeURIComponent(String.interpret(d))
    }
    return {
        initialize: function (c) {
            this._object = Object.isHash(c) ? c.toObject() : Object.clone(c)
        },
        _each: function (d) {
            for (var c in this._object) {
                var e = this._object[c],
                    f = [c, e];
                f.key = c;
                f.value = e;
                d(f)
            }
        },
        set: function (c, d) {
            return this._object[c] = d
        },
        get: function (c) {
            if (this._object[c] !== Object.prototype[c]) {
                return this._object[c]
            }
        },
        unset: function (c) {
            var d = this._object[c];
            delete this._object[c];
            return d
        },
        toObject: function () {
            return Object.clone(this._object)
        },
        keys: function () {
            return this.pluck("key")
        },
        values: function () {
            return this.pluck("value")
        },
        index: function (d) {
            var c = this.detect(function (e) {
                return e.value === d
            });
            return c && c.key
        },
        merge: function (c) {
            return this.clone().update(c)
        },
        update: function (c) {
            return new Hash(c).inject(this, function (d, e) {
                d.set(e.key, e.value);
                return d
            })
        },
        toQueryString: function () {
            return this.inject([], function (e, f) {
                var d = encodeURIComponent(f.key),
                    c = f.value;
                if (c && typeof c == "object") {
                    if (Object.isArray(c)) {
                        return e.concat(c.map(a.curry(d)))
                    }
                } else {
                    e.push(a(d, c))
                }
                return e
            }).join("&")
        },
        inspect: function () {
            return "#<Hash:{" + this.map(function (c) {
                return c.map(Object.inspect).join(": ")
            }).join(", ") + "}>"
        },
        toJSON: function () {
            return Object.toJSON(this.toObject())
        },
        clone: function () {
            return new Hash(this)
        }
    }
})());
Hash.prototype.toTemplateReplacements = Hash.prototype.toObject;
Hash.from = $H;
var ObjectRange = Class.create(Enumerable, {
    initialize: function (d, a, c) {
        this.start = d;
        this.end = a;
        this.exclusive = c
    },
    _each: function (a) {
        var c = this.start;
        while (this.include(c)) {
            a(c);
            c = c.succ()
        }
    },
    include: function (a) {
        if (a < this.start) {
            return false
        }
        if (this.exclusive) {
            return a < this.end
        }
        return a <= this.end
    }
});
var $R = function (d, a, c) {
    return new ObjectRange(d, a, c)
};
var Ajax = {
    getTransport: function () {
        return Try.these(function () {
            return new XMLHttpRequest()
        }, function () {
            return new ActiveXObject("Msxml2.XMLHTTP")
        }, function () {
            return new ActiveXObject("Microsoft.XMLHTTP")
        }) || false
    },
    activeRequestCount: 0
};
Ajax.Responders = {
    responders: [],
    _each: function (a) {
        this.responders._each(a)
    },
    register: function (a) {
        if (!this.include(a)) {
            this.responders.push(a)
        }
    },
    unregister: function (a) {
        this.responders = this.responders.without(a)
    },
    dispatch: function (e, c, d, a) {
        this.each(function (f) {
            if (Object.isFunction(f[e])) {
                try {
                    f[e].apply(f, [c, d, a])
                } catch (g) {}
            }
        })
    }
};
Object.extend(Ajax.Responders, Enumerable);
Ajax.Responders.register({
    onCreate: function () {
        Ajax.activeRequestCount++
    },
    onComplete: function () {
        Ajax.activeRequestCount--
    }
});
Ajax.Base = Class.create({
    initialize: function (a) {
        this.options = {
            method: "post",
            asynchronous: true,
            contentType: "application/x-www-form-urlencoded",
            encoding: "UTF-8",
            parameters: "",
            evalJSON: true,
            evalJS: true
        };
        Object.extend(this.options, a || {});
        this.options.method = this.options.method.toLowerCase();
        if (Object.isString(this.options.parameters)) {
            this.options.parameters = this.options.parameters.toQueryParams()
        } else {
            if (Object.isHash(this.options.parameters)) {
                this.options.parameters = this.options.parameters.toObject()
            }
        }
    }
});
Ajax.Request = Class.create(Ajax.Base, {
    _complete: false,
    initialize: function ($super, c, a) {
        $super(a);
        this.transport = Ajax.getTransport();
        this.request(c)
    },
    request: function (c) {
        this.url = c;
        this.method = this.options.method;
        var f = Object.clone(this.options.parameters);
        if (!["get", "post"].include(this.method)) {
            f._method = this.method;
            this.method = "post"
        }
        this.parameters = f;
        if (f = Object.toQueryString(f)) {
            if (this.method == "get") {
                this.url += (this.url.include("?") ? "&" : "?") + f
            } else {
                if (/Konqueror|Safari|KHTML/.test(navigator.userAgent)) {
                    f += "&_="
                }
            }
        }
        try {
            var a = new Ajax.Response(this);
            if (this.options.onCreate) {
                this.options.onCreate(a)
            }
            Ajax.Responders.dispatch("onCreate", this, a);
            this.transport.open(this.method.toUpperCase(), this.url, this.options.asynchronous);
            if (this.options.asynchronous) {
                this.respondToReadyState.bind(this).defer(1)
            }
            this.transport.onreadystatechange = this.onStateChange.bind(this);
            this.setRequestHeaders();
            this.body = this.method == "post" ? (this.options.postBody || f) : null;this.transport.send(this.body);
            if (!this.options.asynchronous && this.transport.overrideMimeType) {
                this.onStateChange()
            }
        } catch (d) {
            this.dispatchException(d)
        }
    },
    onStateChange: function () {
        var a = this.transport.readyState;
        if (a > 1 && !((a == 4) && this._complete)) {
            this.respondToReadyState(this.transport.readyState)
        }
    },
    setRequestHeaders: function () {
        var f = {
            "X-Requested-With": "XMLHttpRequest",
            "X-Prototype-Version": Prototype.Version,
            Accept: "text/javascript, text/html, application/xml, text/xml, */*"
        };
        if (this.method == "post") {
            f["Content-type"] = this.options.contentType + (this.options.encoding ? "; charset=" + this.options.encoding : "");
            if (this.transport.overrideMimeType && (navigator.userAgent.match(/Gecko\/(\d{4})/) || [0, 2005])[1] < 2005) {
                f.Connection = "close"
            }
        }
        if (typeof this.options.requestHeaders == "object") {
            var d = this.options.requestHeaders;
            if (Object.isFunction(d.push)) {
                for (var c = 0, e = d.length; c < e; c += 2) {
                    f[d[c]] = d[c + 1]
                }
            } else {
                $H(d).each(function (g) {
                    f[g.key] = g.value
                })
            }
        }
        for (var a in f) {
            this.transport.setRequestHeader(a, f[a])
        }
    },
    success: function () {
        var a = this.getStatus();
        return !a || (a >= 200 && a < 300)
    },
    getStatus: function () {
        try {
            return this.transport.status || 0
        } catch (a) {
            return 0
        }
    },
    respondToReadyState: function (a) {
        var d = Ajax.Request.Events[a],
            c = new Ajax.Response(this);
        if (d == "Complete") {
            try {
                this._complete = true;
                (this.options["on" + c.status] || this.options["on" + (this.success() ? "Success" : "Failure")] || Prototype.emptyFunction)(c, c.headerJSON)
            } catch (f) {
                this.dispatchException(f)
            }
            var g = c.getHeader("Content-type");
            if (this.options.evalJS == "force" || (this.options.evalJS && this.isSameOrigin() && g && g.match(/^\s*(text|application)\/(x-)?(java|ecma)script(;.*)?\s*$/i))) {
                this.evalResponse()
            }
        }
        try {
            (this.options["on" + d] || Prototype.emptyFunction)(c, c.headerJSON);
            Ajax.Responders.dispatch("on" + d, this, c, c.headerJSON)
        } catch (f) {
            this.dispatchException(f)
        }
        if (d == "Complete") {
            this.transport.onreadystatechange = Prototype.emptyFunction
        }
    },
    isSameOrigin: function () {
        var a = this.url.match(/^\s*https?:\/\/[^\/]*/);
        return !a || (a[0] == "#{protocol}//#{domain}#{port}".interpolate({
            protocol: location.protocol,
            domain: document.domain,
            port: location.port ? ":" + location.port : ""
        }))
    },
    getHeader: function (a) {
        try {
            return this.transport.getResponseHeader(a) || null
        } catch (c) {
            return null
        }
    },
    evalResponse: function () {
        try {
            return eval((this.transport.responseText || "").unfilterJSON())
        } catch (e) {
            this.dispatchException(e)
        }
    },
    dispatchException: function (a) {
        (this.options.onException || Prototype.emptyFunction)(this, a);
        Ajax.Responders.dispatch("onException", this, a)
    }
});
Ajax.Request.Events = ["Uninitialized", "Loading", "Loaded", "Interactive", "Complete"];
Ajax.Response = Class.create({
    initialize: function (d) {
        this.request = d;
        var e = this.transport = d.transport,
            a = this.readyState = e.readyState;
        if ((a > 2 && !Prototype.Browser.IE) || a == 4) {
            this.status = this.getStatus();
            this.statusText = this.getStatusText();
            this.responseText = String.interpret(e.responseText);
            this.headerJSON = this._getHeaderJSON()
        }
        if (a == 4) {
            var c = e.responseXML;
            this.responseXML = Object.isUndefined(c) ? null : c;this.responseJSON = this._getResponseJSON()
        }
    },
    status: 0,
    statusText: "",
    getStatus: Ajax.Request.prototype.getStatus,
    getStatusText: function () {
        try {
            return this.transport.statusText || ""
        } catch (a) {
            return ""
        }
    },
    getHeader: Ajax.Request.prototype.getHeader,
    getAllHeaders: function () {
        try {
            return this.getAllResponseHeaders()
        } catch (a) {
            return null
        }
    },
    getResponseHeader: function (a) {
        return this.transport.getResponseHeader(a)
    },
    getAllResponseHeaders: function () {
        return this.transport.getAllResponseHeaders()
    },
    _getHeaderJSON: function () {
        var a = this.getHeader("X-JSON");
        if (!a) {
            return null
        }
        a = decodeURIComponent(escape(a));
        try {
            return a.evalJSON(this.request.options.sanitizeJSON || !this.request.isSameOrigin())
        } catch (c) {
            this.request.dispatchException(c)
        }
    },
    _getResponseJSON: function () {
        var a = this.request.options;
        if (!a.evalJSON || (a.evalJSON != "force" && !(this.getHeader("Content-type") || "").include("application/json")) || this.responseText.blank()) {
            return null
        }
        try {
            return this.responseText.evalJSON(a.sanitizeJSON || !this.request.isSameOrigin())
        } catch (c) {
            this.request.dispatchException(c)
        }
    }
});
Ajax.Updater = Class.create(Ajax.Request, {
    initialize: function ($super, a, d, c) {
        this.container = {
            success: (a.success || a),
            failure: (a.failure || (a.success ? null : a))
        };
        c = Object.clone(c);
        var e = c.onComplete;
        c.onComplete = (function (f, g) {
            this.updateContent(f.responseText);
            if (Object.isFunction(e)) {
                e(f, g)
            }
        }).bind(this);
        $super(d, c)
    },
    updateContent: function (e) {
        var d = this.container[this.success() ? "success" : "failure"],
            a = this.options;
        if (!a.evalScripts) {
            e = e.stripScripts()
        }
        if (d = $(d)) {
            if (a.insertion) {
                if (Object.isString(a.insertion)) {
                    var c = {};
                    c[a.insertion] = e;
                    d.insert(c)
                } else {
                    a.insertion(d, e)
                }
            } else {
                d.update(e)
            }
        }
    }
});
Ajax.PeriodicalUpdater = Class.create(Ajax.Base, {
    initialize: function ($super, a, d, c) {
        $super(c);
        this.onComplete = this.options.onComplete;
        this.frequency = (this.options.frequency || 2);
        this.decay = (this.options.decay || 1);
        this.updater = {};
        this.container = a;
        this.url = d;
        this.start()
    },
    start: function () {
        this.options.onComplete = this.updateComplete.bind(this);
        this.onTimerEvent()
    },
    stop: function () {
        this.updater.options.onComplete = undefined;
        clearTimeout(this.timer);
        (this.onComplete || Prototype.emptyFunction).apply(this, arguments)
    },
    updateComplete: function (a) {
        if (this.options.decay) {
            this.decay = (a.responseText == this.lastText ? this.decay * this.options.decay : 1);
            this.lastText = a.responseText
        }
        this.timer = this.onTimerEvent.bind(this).delay(this.decay * this.frequency)
    },
    onTimerEvent: function () {
        this.updater = new Ajax.Updater(this.container, this.url, this.options)
    }
});

function $(c) {
    if (arguments.length > 1) {
        for (var a = 0, e = [], d = arguments.length; a < d; a++) {
            e.push($(arguments[a]))
        }
        return e
    }
    if (Object.isString(c)) {
        c = document.getElementById(c)
    }
    return Element.extend(c)
}
if (Prototype.BrowserFeatures.XPath) {
    document._getElementsByXPath = function (g, a) {
        var d = [];
        var f = document.evaluate(g, $(a) || document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
        for (var c = 0, e = f.snapshotLength; c < e; c++) {
            d.push(Element.extend(f.snapshotItem(c)))
        }
        return d
    }
}
if (!window.Node) {
    var Node = {}
}
if (!Node.ELEMENT_NODE) {
    Object.extend(Node, {
        ELEMENT_NODE: 1,
        ATTRIBUTE_NODE: 2,
        TEXT_NODE: 3,
        CDATA_SECTION_NODE: 4,
        ENTITY_REFERENCE_NODE: 5,
        ENTITY_NODE: 6,
        PROCESSING_INSTRUCTION_NODE: 7,
        COMMENT_NODE: 8,
        DOCUMENT_NODE: 9,
        DOCUMENT_TYPE_NODE: 10,
        DOCUMENT_FRAGMENT_NODE: 11,
        NOTATION_NODE: 12
    })
}(function () {
    var a = this.Element;
    this.Element = function (e, d) {
        d = d || {};
        e = e.toLowerCase();
        var c = Element.cache;
        if (Prototype.Browser.IE && d.name) {
            e = "<" + e + ' name="' + d.name + '">';
            delete d.name;
            return Element.writeAttribute(document.createElement(e), d)
        }
        if (!c[e]) {
            c[e] = Element.extend(document.createElement(e))
        }
        return Element.writeAttribute(c[e].cloneNode(false), d)
    };
    Object.extend(this.Element, a || {});
    if (a) {
        this.Element.prototype = a.prototype
    }
}).call(window);
Element.cache = {};
Element.Methods = {
    visible: function (a) {
        return $(a).style.display != "none"
    },
    toggle: function (a) {
        a = $(a);
        Element[Element.visible(a) ? "hide" : "show"](a);
        return a
    },
    hide: function (a) {
        a = $(a);
        a.style.display = "none";
        return a
    },
    show: function (a) {
        a = $(a);
        a.style.display = "";
        return a
    },
    remove: function (a) {
        a = $(a);
        a.parentNode.removeChild(a);
        return a
    },
    update: function (a, c) {
        a = $(a);
        if (c && c.toElement) {
            c = c.toElement()
        }
        if (Object.isElement(c)) {
            return a.update().insert(c)
        }
        c = Object.toHTML(c);
        a.innerHTML = c.stripScripts();
        c.evalScripts.bind(c).defer();
        return a
    },
    replace: function (c, d) {
        c = $(c);
        if (d && d.toElement) {
            d = d.toElement()
        } else {
            if (!Object.isElement(d)) {
                d = Object.toHTML(d);
                var a = c.ownerDocument.createRange();
                a.selectNode(c);
                d.evalScripts.bind(d).defer();
                d = a.createContextualFragment(d.stripScripts())
            }
        }
        c.parentNode.replaceChild(d, c);
        return c
    },
    insert: function (d, f) {
        d = $(d);
        if (Object.isString(f) || Object.isNumber(f) || Object.isElement(f) || (f && (f.toElement || f.toHTML))) {
            f = {
                bottom: f
            }
        }
        var e, g, c, h;
        for (var a in f) {
            e = f[a];
            a = a.toLowerCase();
            g = Element._insertionTranslations[a];
            if (e && e.toElement) {
                e = e.toElement()
            }
            if (Object.isElement(e)) {
                g(d, e);
                continue
            }
            e = Object.toHTML(e);
            c = ((a == "before" || a == "after") ? d.parentNode : d).tagName.toUpperCase();
            h = Element._getContentFromAnonymousElement(c, e.stripScripts());
            if (a == "top" || a == "after") {
                h.reverse()
            }
            h.each(g.curry(d));
            e.evalScripts.bind(e).defer()
        }
        return d
    },
    wrap: function (c, d, a) {
        c = $(c);
        if (Object.isElement(d)) {
            $(d).writeAttribute(a || {})
        } else {
            if (Object.isString(d)) {
                d = new Element(d, a)
            } else {
                d = new Element("div", d)
            }
        }
        if (c.parentNode) {
            c.parentNode.replaceChild(d, c)
        }
        d.appendChild(c);
        return d
    },
    inspect: function (c) {
        c = $(c);
        var a = "<" + c.tagName.toLowerCase();
        $H({
            id: "id",
            className: "class"
        }).each(function (g) {
            var f = g.first(),
                d = g.last();
            var e = (c[f] || "").toString();
            if (e) {
                a += " " + d + "=" + e.inspect(true)
            }
        });
        return a + ">"
    },
    recursivelyCollect: function (a, d) {
        a = $(a);
        var c = [];
        while (a = a[d]) {
            if (a.nodeType == 1) {
                c.push(Element.extend(a))
            }
        }
        return c
    },
    ancestors: function (a) {
        return $(a).recursivelyCollect("parentNode")
    },
    descendants: function (a) {
        return $(a).select("*")
    },
    firstDescendant: function (a) {
        a = $(a).firstChild;
        while (a && a.nodeType != 1) {
            a = a.nextSibling
        }
        return $(a)
    },
    immediateDescendants: function (a) {
        if (!(a = $(a).firstChild)) {
            return []
        }
        while (a && a.nodeType != 1) {
            a = a.nextSibling
        }
        if (a) {
            return [a].concat($(a).nextSiblings())
        }
        return []
    },
    previousSiblings: function (a) {
        return $(a).recursivelyCollect("previousSibling")
    },
    nextSiblings: function (a) {
        return $(a).recursivelyCollect("nextSibling")
    },
    siblings: function (a) {
        a = $(a);
        return a.previousSiblings().reverse().concat(a.nextSiblings())
    },
    match: function (c, a) {
        if (Object.isString(a)) {
            a = new Selector(a)
        }
        return a.match($(c))
    },
    up: function (c, e, a) {
        c = $(c);
        if (arguments.length == 1) {
            return $(c.parentNode)
        }
        var d = c.ancestors();
        return Object.isNumber(e) ? d[e] : Selector.findElement(d, e, a)
    },
    down: function (c, d, a) {
        c = $(c);
        if (arguments.length == 1) {
            return c.firstDescendant()
        }
        return Object.isNumber(d) ? c.descendants()[d] : Element.select(c, d)[a || 0]
    },
    previous: function (c, e, a) {
        c = $(c);
        if (arguments.length == 1) {
            return $(Selector.handlers.previousElementSibling(c))
        }
        var d = c.previousSiblings();
        return Object.isNumber(e) ? d[e] : Selector.findElement(d, e, a)
    },
    next: function (d, e, c) {
        d = $(d);
        if (arguments.length == 1) {
            return $(Selector.handlers.nextElementSibling(d))
        }
        var a = d.nextSiblings();
        return Object.isNumber(e) ? a[e] : Selector.findElement(a, e, c)
    },
    select: function () {
        var a = $A(arguments),
            c = $(a.shift());
        return Selector.findChildElements(c, a)
    },
    adjacent: function () {
        var a = $A(arguments),
            c = $(a.shift());
        return Selector.findChildElements(c.parentNode, a).without(c)
    },
    identify: function (c) {
        c = $(c);
        var d = c.readAttribute("id"),
            a = arguments.callee;
        if (d) {
            return d
        }
        do {
            d = "anonymous_element_" + a.counter++
        } while ($(d));
        c.writeAttribute("id", d);
        return d
    },
    readAttribute: function (d, a) {
        d = $(d);
        if (Prototype.Browser.IE) {
            var c = Element._attributeTranslations.read;
            if (c.values[a]) {
                return c.values[a](d, a)
            }
            if (c.names[a]) {
                a = c.names[a]
            }
            if (a.include(":")) {
                return (!d.attributes || !d.attributes[a]) ? null : d.attributes[a].value
            }
        }
        return d.getAttribute(a)
    },
    writeAttribute: function (f, d, g) {
        f = $(f);
        var c = {},
            e = Element._attributeTranslations.write;
        if (typeof d == "object") {
            c = d
        } else {
            c[d] = Object.isUndefined(g) ? true : g
        }
        for (var a in c) {
            d = e.names[a] || a;
            g = c[a];
            if (e.values[a]) {
                d = e.values[a](f, g)
            }
            if (g === false || g === null) {
                f.removeAttribute(d)
            } else {
                if (g === true) {
                    f.setAttribute(d, d)
                } else {
                    f.setAttribute(d, g)
                }
            }
        }
        return f
    },
    getHeight: function (a) {
        return $(a).getDimensions().height
    },
    getWidth: function (a) {
        return $(a).getDimensions().width
    },
    classNames: function (a) {
        return new Element.ClassNames(a)
    },
    hasClassName: function (a, c) {
        if (!(a = $(a))) {
            return
        }
        var d = a.className;
        return (d.length > 0 && (d == c || new RegExp("(^|\\s)" + c + "(\\s|$)").test(d)))
    },
    addClassName: function (a, c) {
        if (!(a = $(a))) {
            return
        }
        if (!a.hasClassName(c)) {
            a.className += (a.className ? " " : "") + c
        }
        return a
    },
    removeClassName: function (a, c) {
        if (!(a = $(a))) {
            return
        }
        a.className = a.className.replace(new RegExp("(^|\\s+)" + c + "(\\s+|$)"), " ").strip();
        return a
    },
    toggleClassName: function (a, c) {
        if (!(a = $(a))) {
            return
        }
        return a[a.hasClassName(c) ? "removeClassName" : "addClassName"](c)
    },
    cleanWhitespace: function (c) {
        c = $(c);
        var d = c.firstChild;
        while (d) {
            var a = d.nextSibling;
            if (d.nodeType == 3 && !/\S/.test(d.nodeValue)) {
                c.removeChild(d)
            }
            d = a
        }
        return c
    },
    empty: function (a) {
        return $(a).innerHTML.blank()
    },
    descendantOf: function (c, a) {
        c = $(c), a = $(a);
        if (c.compareDocumentPosition) {
            return (c.compareDocumentPosition(a) & 8) === 8
        }
        if (a.contains) {
            return a.contains(c) && a !== c
        }
        while (c = c.parentNode) {
            if (c == a) {
                return true
            }
        }
        return false
    },
    scrollTo: function (a) {
        a = $(a);
        var c = a.cumulativeOffset();
        window.scrollTo(c[0], c[1]);
        return a
    },
    getStyle: function (c, d) {
        c = $(c);
        d = d == "float" ? "cssFloat" : d.camelize();
        var e = c.style[d];
        if (!e || e == "auto") {
            var a = document.defaultView.getComputedStyle(c, null);
            e = a ? a[d] : null
        }
        if (d == "opacity") {
            return e ? parseFloat(e) : 1
        }
        return e == "auto" ? null : e
    },
    getOpacity: function (a) {
        return $(a).getStyle("opacity")
    },
    setStyle: function (c, d) {
        c = $(c);
        var f = c.style,
            a;
        if (Object.isString(d)) {
            c.style.cssText += ";" + d;
            return d.include("opacity") ? c.setOpacity(d.match(/opacity:\s*(\d?\.?\d*)/)[1]) : c
        }
        for (var e in d) {
            if (e == "opacity") {
                c.setOpacity(d[e])
            } else {
                f[(e == "float" || e == "cssFloat") ? (Object.isUndefined(f.styleFloat) ? "cssFloat" : "styleFloat") : e] = d[e]
            }
        }
        return c
    },
    setOpacity: function (a, c) {
        a = $(a);
        a.style.opacity = (c == 1 || c === "") ? "" : (c < 0.00001) ? 0 : c;
        return a
    },
    getDimensions: function (d) {
        d = $(d);
        var h = d.getStyle("display");
        if (h != "none" && h != null) {
            return {
                width: d.offsetWidth,
                height: d.offsetHeight
            }
        }
        var c = d.style;
        var g = c.visibility;
        var e = c.position;
        var a = c.display;
        c.visibility = "hidden";
        c.position = "absolute";
        c.display = "block";
        var j = d.clientWidth;
        var f = d.clientHeight;
        c.display = a;
        c.position = e;
        c.visibility = g;
        return {
            width: j,
            height: f
        }
    },
    makePositioned: function (a) {
        a = $(a);
        var c = Element.getStyle(a, "position");
        if (c == "static" || !c) {
            a._madePositioned = true;
            a.style.position = "relative";
            if (Prototype.Browser.Opera) {
                a.style.top = 0;
                a.style.left = 0
            }
        }
        return a
    },
    undoPositioned: function (a) {
        a = $(a);
        if (a._madePositioned) {
            a._madePositioned = undefined;
            a.style.position = a.style.top = a.style.left = a.style.bottom = a.style.right = ""
        }
        return a
    },
    makeClipping: function (a) {
        a = $(a);
        if (a._overflow) {
            return a
        }
        a._overflow = Element.getStyle(a, "overflow") || "auto";
        if (a._overflow !== "hidden") {
            a.style.overflow = "hidden"
        }
        return a
    },
    undoClipping: function (a) {
        a = $(a);
        if (!a._overflow) {
            return a
        }
        a.style.overflow = a._overflow == "auto" ? "" : a._overflow;a._overflow = null;
        return a
    },
    cumulativeOffset: function (c) {
        var a = 0,
            d = 0;
        do {
            a += c.offsetTop || 0;
            d += c.offsetLeft || 0;
            c = c.offsetParent
        } while (c);
        return Element._returnOffset(d, a)
    },
    positionedOffset: function (c) {
        var a = 0,
            e = 0;
        do {
            a += c.offsetTop || 0;
            e += c.offsetLeft || 0;
            c = c.offsetParent;
            if (c) {
                if (c.tagName.toUpperCase() == "BODY") {
                    break
                }
                var d = Element.getStyle(c, "position");
                if (d !== "static") {
                    break
                }
            }
        } while (c);
        return Element._returnOffset(e, a)
    },
    absolutize: function (c) {
        c = $(c);
        if (c.getStyle("position") == "absolute") {
            return c
        }
        var e = c.positionedOffset();
        var g = e[1];
        var f = e[0];
        var d = c.clientWidth;
        var a = c.clientHeight;
        c._originalLeft = f - parseFloat(c.style.left || 0);
        c._originalTop = g - parseFloat(c.style.top || 0);
        c._originalWidth = c.style.width;
        c._originalHeight = c.style.height;
        c.style.position = "absolute";
        c.style.top = g + "px";
        c.style.left = f + "px";
        c.style.width = d + "px";
        c.style.height = a + "px";
        return c
    },
    relativize: function (a) {
        a = $(a);
        if (a.getStyle("position") == "relative") {
            return a
        }
        a.style.position = "relative";
        var d = parseFloat(a.style.top || 0) - (a._originalTop || 0);
        var c = parseFloat(a.style.left || 0) - (a._originalLeft || 0);
        a.style.top = d + "px";
        a.style.left = c + "px";
        a.style.height = a._originalHeight;
        a.style.width = a._originalWidth;
        return a
    },
    cumulativeScrollOffset: function (c) {
        var a = 0,
            d = 0;
        do {
            a += c.scrollTop || 0;
            d += c.scrollLeft || 0;
            c = c.parentNode
        } while (c);
        return Element._returnOffset(d, a)
    },
    getOffsetParent: function (a) {
        if (a.offsetParent) {
            return $(a.offsetParent)
        }
        if (a == document.body) {
            return $(a)
        }
        while ((a = a.parentNode) && a != document.body) {
            if (Element.getStyle(a, "position") != "static") {
                return $(a)
            }
        }
        return $(document.body)
    },
    viewportOffset: function (e) {
        var a = 0,
            d = 0;
        var c = e;
        do {
            a += c.offsetTop || 0;
            d += c.offsetLeft || 0;
            if (c.offsetParent == document.body && Element.getStyle(c, "position") == "absolute") {
                break
            }
        } while (c = c.offsetParent);
        c = e;
        do {
            if (!Prototype.Browser.Opera || (c.tagName && (c.tagName.toUpperCase() == "BODY"))) {
                a -= c.scrollTop || 0;
                d -= c.scrollLeft || 0
            }
        } while (c = c.parentNode);
        return Element._returnOffset(d, a)
    },
    clonePosition: function (c, e) {
        var a = Object.extend({
            setLeft: true,
            setTop: true,
            setWidth: true,
            setHeight: true,
            offsetTop: 0,
            offsetLeft: 0
        }, arguments[2] || {});
        e = $(e);
        var f = e.viewportOffset();
        c = $(c);
        var g = [0, 0];
        var d = null;
        if (Element.getStyle(c, "position") == "absolute") {
            d = c.getOffsetParent();
            g = d.viewportOffset()
        }
        if (d == document.body) {
            g[0] -= document.body.offsetLeft;
            g[1] -= document.body.offsetTop
        }
        if (a.setLeft) {
            c.style.left = (f[0] - g[0] + a.offsetLeft) + "px"
        }
        if (a.setTop) {
            c.style.top = (f[1] - g[1] + a.offsetTop) + "px"
        }
        if (a.setWidth) {
            c.style.width = e.offsetWidth + "px"
        }
        if (a.setHeight) {
            c.style.height = e.offsetHeight + "px"
        }
        return c
    }
};
Element.Methods.identify.counter = 1;
Object.extend(Element.Methods, {
    getElementsBySelector: Element.Methods.select,
    childElements: Element.Methods.immediateDescendants
});
Element._attributeTranslations = {
    write: {
        names: {
            className: "class",
            htmlFor: "for"
        },
        values: {}
    }
};
if (Prototype.Browser.Opera) {
    Element.Methods.getStyle = Element.Methods.getStyle.wrap(function (e, c, d) {
        switch (d) {
        case "left":
        case "top":
        case "right":
        case "bottom":
            if (e(c, "position") === "static") {
                return null
            }
        case "height":
        case "width":
            if (!Element.visible(c)) {
                return null
            }
            var f = parseInt(e(c, d), 10);
            if (f !== c["offset" + d.capitalize()]) {
                return f + "px"
            }
            var a;
            if (d === "height") {
                a = ["border-top-width", "padding-top", "padding-bottom", "border-bottom-width"]
            } else {
                a = ["border-left-width", "padding-left", "padding-right", "border-right-width"]
            }
            return a.inject(f, function (g, h) {
                var j = e(c, h);
                return j === null ? g : g - parseInt(j, 10)
            }) + "px";
        default:
            return e(c, d)
        }
    });
    Element.Methods.readAttribute = Element.Methods.readAttribute.wrap(function (d, a, c) {
        if (c === "title") {
            return a.title
        }
        return d(a, c)
    })
} else {
    if (Prototype.Browser.IE) {
        Element.Methods.getOffsetParent = Element.Methods.getOffsetParent.wrap(function (d, c) {
            c = $(c);
            try {
                c.offsetParent
            } catch (g) {
                return $(document.body)
            }
            var a = c.getStyle("position");
            if (a !== "static") {
                return d(c)
            }
            c.setStyle({
                position: "relative"
            });
            var f = d(c);
            c.setStyle({
                position: a
            });
            return f
        });
        $w("positionedOffset viewportOffset").each(function (a) {
            Element.Methods[a] = Element.Methods[a].wrap(function (g, d) {
                d = $(d);
                try {
                    d.offsetParent
                } catch (j) {
                    return Element._returnOffset(0, 0)
                }
                var c = d.getStyle("position");
                if (c !== "static") {
                    return g(d)
                }
                var f = d.getOffsetParent();
                if (f && f.getStyle("position") === "fixed") {
                    f.setStyle({
                        zoom: 1
                    })
                }
                d.setStyle({
                    position: "relative"
                });
                var h = g(d);
                d.setStyle({
                    position: c
                });
                return h
            })
        });
        Element.Methods.cumulativeOffset = Element.Methods.cumulativeOffset.wrap(function (c, a) {
            try {
                a.offsetParent
            } catch (d) {
                return Element._returnOffset(0, 0)
            }
            return c(a)
        });
        Element.Methods.getStyle = function (a, c) {
            a = $(a);
            c = (c == "float" || c == "cssFloat") ? "styleFloat" : c.camelize();
            var d = a.style[c];
            if (!d && a.currentStyle) {
                d = a.currentStyle[c]
            }
            if (c == "opacity") {
                if (d = (a.getStyle("filter") || "").match(/alpha\(opacity=(.*)\)/)) {
                    if (d[1]) {
                        return parseFloat(d[1]) / 100
                    }
                }
                return 1
            }
            if (d == "auto") {
                if ((c == "width" || c == "height") && (a.getStyle("display") != "none")) {
                    return a["offset" + c.capitalize()] + "px"
                }
                return null
            }
            return d
        };
        Element.Methods.setOpacity = function (c, f) {
            function g(h) {
                return h.replace(/alpha\([^\)]*\)/gi, "")
            }
            c = $(c);
            var a = c.currentStyle;
            if ((a && !a.hasLayout) || (!a && c.style.zoom == "normal")) {
                c.style.zoom = 1
            }
            var e = c.getStyle("filter"),
                d = c.style;
            if (f == 1 || f === "") {
                (e = g(e)) ? d.filter = e : d.removeAttribute("filter");
                return c
            } else {
                if (f < 0.00001) {
                    f = 0
                }
            }
            d.filter = g(e) + "alpha(opacity=" + (f * 100) + ")";
            return c
        };
        Element._attributeTranslations = {
            read: {
                names: {
                    "class": "className",
                    "for": "htmlFor"
                },
                values: {
                    _getAttr: function (a, c) {
                        return a.getAttribute(c, 2)
                    },
                    _getAttrNode: function (a, d) {
                        var c = a.getAttributeNode(d);
                        return c ? c.value : ""
                    },
                    _getEv: function (a, c) {
                        c = a.getAttribute(c);
                        return c ? c.toString().slice(23, -2) : null
                    },
                    _flag: function (a, c) {
                        return $(a).hasAttribute(c) ? c : null
                    },
                    style: function (a) {
                        return a.style.cssText.toLowerCase()
                    },
                    title: function (a) {
                        return a.title
                    }
                }
            }
        };
        Element._attributeTranslations.write = {
            names: Object.extend({
                cellpadding: "cellPadding",
                cellspacing: "cellSpacing"
            }, Element._attributeTranslations.read.names),
            values: {
                checked: function (a, c) {
                    a.checked = !! c
                },
                style: function (a, c) {
                    a.style.cssText = c ? c : ""
                }
            }
        };
        Element._attributeTranslations.has = {};
        $w("colSpan rowSpan vAlign dateTime accessKey tabIndex encType maxLength readOnly longDesc frameBorder").each(function (a) {
            Element._attributeTranslations.write.names[a.toLowerCase()] = a;
            Element._attributeTranslations.has[a.toLowerCase()] = a
        });
        (function (a) {
            Object.extend(a, {
                href: a._getAttr,
                src: a._getAttr,
                type: a._getAttr,
                action: a._getAttrNode,
                disabled: a._flag,
                checked: a._flag,
                readonly: a._flag,
                multiple: a._flag,
                onload: a._getEv,
                onunload: a._getEv,
                onclick: a._getEv,
                ondblclick: a._getEv,
                onmousedown: a._getEv,
                onmouseup: a._getEv,
                onmouseover: a._getEv,
                onmousemove: a._getEv,
                onmouseout: a._getEv,
                onfocus: a._getEv,
                onblur: a._getEv,
                onkeypress: a._getEv,
                onkeydown: a._getEv,
                onkeyup: a._getEv,
                onsubmit: a._getEv,
                onreset: a._getEv,
                onselect: a._getEv,
                onchange: a._getEv
            })
        })(Element._attributeTranslations.read.values)
    } else {
        if (Prototype.Browser.Gecko && /rv:1\.8\.0/.test(navigator.userAgent)) {
            Element.Methods.setOpacity = function (a, c) {
                a = $(a);
                a.style.opacity = (c == 1) ? 0.999999 : (c === "") ? "" : (c < 0.00001) ? 0 : c;
                return a
            }
        } else {
            if (Prototype.Browser.WebKit) {
                Element.Methods.setOpacity = function (a, c) {
                    a = $(a);
                    a.style.opacity = (c == 1 || c === "") ? "" : (c < 0.00001) ? 0 : c;
                    if (c == 1) {
                        if (a.tagName.toUpperCase() == "IMG" && a.width) {
                            a.width++;
                            a.width--
                        } else {
                            try {
                                var f = document.createTextNode(" ");
                                a.appendChild(f);
                                a.removeChild(f)
                            } catch (d) {}
                        }
                    }
                    return a
                };
                Element.Methods.cumulativeOffset = function (c) {
                    var a = 0,
                        d = 0;
                    do {
                        a += c.offsetTop || 0;
                        d += c.offsetLeft || 0;
                        if (c.offsetParent == document.body) {
                            if (Element.getStyle(c, "position") == "absolute") {
                                break
                            }
                        }
                        c = c.offsetParent
                    } while (c);
                    return Element._returnOffset(d, a)
                }
            }
        }
    }
}
if (Prototype.Browser.IE || Prototype.Browser.Opera) {
    Element.Methods.update = function (c, d) {
        c = $(c);
        if (d && d.toElement) {
            d = d.toElement()
        }
        if (Object.isElement(d)) {
            return c.update().insert(d)
        }
        d = Object.toHTML(d);
        var a = c.tagName.toUpperCase();
        if (a in Element._insertionTranslations.tags) {
            $A(c.childNodes).each(function (e) {
                c.removeChild(e)
            });
            Element._getContentFromAnonymousElement(a, d.stripScripts()).each(function (e) {
                c.appendChild(e)
            })
        } else {
            c.innerHTML = d.stripScripts()
        }
        d.evalScripts.bind(d).defer();
        return c
    }
}
if ("outerHTML" in document.createElement("div")) {
    Element.Methods.replace = function (d, f) {
        d = $(d);
        if (f && f.toElement) {
            f = f.toElement()
        }
        if (Object.isElement(f)) {
            d.parentNode.replaceChild(f, d);
            return d
        }
        f = Object.toHTML(f);
        var e = d.parentNode,
            c = e.tagName.toUpperCase();
        if (Element._insertionTranslations.tags[c]) {
            var g = d.next();
            var a = Element._getContentFromAnonymousElement(c, f.stripScripts());
            e.removeChild(d);
            if (g) {
                a.each(function (h) {
                    e.insertBefore(h, g)
                })
            } else {
                a.each(function (h) {
                    e.appendChild(h)
                })
            }
        } else {
            d.outerHTML = f.stripScripts()
        }
        f.evalScripts.bind(f).defer();
        return d
    }
}
Element._returnOffset = function (c, d) {
    var a = [c, d];
    a.left = c;
    a.top = d;
    return a
};
Element._getContentFromAnonymousElement = function (d, c) {
    var e = new Element("div"),
        a = Element._insertionTranslations.tags[d];
    if (a) {
        e.innerHTML = a[0] + c + a[1];
        a[2].times(function () {
            e = e.firstChild
        })
    } else {
        e.innerHTML = c
    }
    return $A(e.childNodes)
};
Element._insertionTranslations = {
    before: function (a, c) {
        a.parentNode.insertBefore(c, a)
    },
    top: function (a, c) {
        a.insertBefore(c, a.firstChild)
    },
    bottom: function (a, c) {
        a.appendChild(c)
    },
    after: function (a, c) {
        a.parentNode.insertBefore(c, a.nextSibling)
    },
    tags: {
        TABLE: ["<table>", "</table>", 1],
        TBODY: ["<table><tbody>", "</tbody></table>", 2],
        TR: ["<table><tbody><tr>", "</tr></tbody></table>", 3],
        TD: ["<table><tbody><tr><td>", "</td></tr></tbody></table>", 4],
        SELECT: ["<select>", "</select>", 1]
    }
};
(function () {
    Object.extend(this.tags, {
        THEAD: this.tags.TBODY,
        TFOOT: this.tags.TBODY,
        TH: this.tags.TD
    })
}).call(Element._insertionTranslations);
Element.Methods.Simulated = {
    hasAttribute: function (a, d) {
        d = Element._attributeTranslations.has[d] || d;
        var c = $(a).getAttributeNode(d);
        return !!(c && c.specified)
    }
};
Element.Methods.ByTag = {};
Object.extend(Element, Element.Methods);
if (!Prototype.BrowserFeatures.ElementExtensions && document.createElement("div")["__proto__"]) {
    window.HTMLElement = {};
    window.HTMLElement.prototype = document.createElement("div")["__proto__"];
    Prototype.BrowserFeatures.ElementExtensions = true
}
Element.extend = (function () {
    if (Prototype.BrowserFeatures.SpecificElementExtensions) {
        return Prototype.K
    }
    var a = {},
        c = Element.Methods.ByTag;
    var d = Object.extend(function (g) {
        if (!g || g._extendedByPrototype || g.nodeType != 1 || g == window) {
            return g
        }
        var e = Object.clone(a),
            f = g.tagName.toUpperCase(),
            j, h;
        if (c[f]) {
            Object.extend(e, c[f])
        }
        for (j in e) {
            h = e[j];
            if (Object.isFunction(h) && !(j in g)) {
                g[j] = h.methodize()
            }
        }
        g._extendedByPrototype = Prototype.emptyFunction;
        return g
    }, {
        refresh: function () {
            if (!Prototype.BrowserFeatures.ElementExtensions) {
                Object.extend(a, Element.Methods);
                Object.extend(a, Element.Methods.Simulated)
            }
        }
    });
    d.refresh();
    return d
})();
Element.hasAttribute = function (a, c) {
    if (a.hasAttribute) {
        return a.hasAttribute(c)
    }
    return Element.Methods.Simulated.hasAttribute(a, c)
};
Element.addMethods = function (d) {
    var j = Prototype.BrowserFeatures,
        e = Element.Methods.ByTag;
    if (!d) {
        Object.extend(Form, Form.Methods);
        Object.extend(Form.Element, Form.Element.Methods);
        Object.extend(Element.Methods.ByTag, {
            FORM: Object.clone(Form.Methods),
            INPUT: Object.clone(Form.Element.Methods),
            SELECT: Object.clone(Form.Element.Methods),
            TEXTAREA: Object.clone(Form.Element.Methods)
        })
    }
    if (arguments.length == 2) {
        var c = d;
        d = arguments[1]
    }
    if (!c) {
        Object.extend(Element.Methods, d || {})
    } else {
        if (Object.isArray(c)) {
            c.each(h)
        } else {
            h(c)
        }
    }
    function h(l) {
        l = l.toUpperCase();
        if (!Element.Methods.ByTag[l]) {
            Element.Methods.ByTag[l] = {}
        }
        Object.extend(Element.Methods.ByTag[l], d)
    }
    function a(o, m, l) {
        l = l || false;
        for (var r in o) {
            var q = o[r];
            if (!Object.isFunction(q)) {
                continue
            }
            if (!l || !(r in m)) {
                m[r] = q.methodize()
            }
        }
    }
    function f(o) {
        var l;
        var m = {
            OPTGROUP: "OptGroup",
            TEXTAREA: "TextArea",
            P: "Paragraph",
            FIELDSET: "FieldSet",
            UL: "UList",
            OL: "OList",
            DL: "DList",
            DIR: "Directory",
            H1: "Heading",
            H2: "Heading",
            H3: "Heading",
            H4: "Heading",
            H5: "Heading",
            H6: "Heading",
            Q: "Quote",
            INS: "Mod",
            DEL: "Mod",
            A: "Anchor",
            IMG: "Image",
            CAPTION: "TableCaption",
            COL: "TableCol",
            COLGROUP: "TableCol",
            THEAD: "TableSection",
            TFOOT: "TableSection",
            TBODY: "TableSection",
            TR: "TableRow",
            TH: "TableCell",
            TD: "TableCell",
            FRAMESET: "FrameSet",
            IFRAME: "IFrame"
        };
        if (m[o]) {
            l = "HTML" + m[o] + "Element"
        }
        if (window[l]) {
            return window[l]
        }
        l = "HTML" + o + "Element";
        if (window[l]) {
            return window[l]
        }
        l = "HTML" + o.capitalize() + "Element";
        if (window[l]) {
            return window[l]
        }
        window[l] = {};
        window[l].prototype = document.createElement(o)["__proto__"];
        return window[l]
    }
    if (j.ElementExtensions) {
        a(Element.Methods, HTMLElement.prototype);
        a(Element.Methods.Simulated, HTMLElement.prototype, true)
    }
    if (j.SpecificElementExtensions) {
        for (var k in Element.Methods.ByTag) {
            var g = f(k);
            if (Object.isUndefined(g)) {
                continue
            }
            a(e[k], g.prototype)
        }
    }
    Object.extend(Element, Element.Methods);
    delete Element.ByTag;
    if (Element.extend.refresh) {
        Element.extend.refresh()
    }
    Element.cache = {}
};
document.viewport = {
    getDimensions: function () {
        var a = {},
            c = Prototype.Browser;
        $w("width height").each(function (f) {
            var e = f.capitalize();
            if (c.WebKit && !document.evaluate) {
                a[f] = self["inner" + e]
            } else {
                if (c.Opera && parseFloat(window.opera.version()) < 9.5) {
                    a[f] = document.body["client" + e]
                } else {
                    a[f] = document.documentElement["client" + e]
                }
            }
        });
        return a
    },
    getWidth: function () {
        return this.getDimensions().width
    },
    getHeight: function () {
        return this.getDimensions().height
    },
    getScrollOffsets: function () {
        return Element._returnOffset(window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft, window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop)
    }
};
var Selector = Class.create({
    initialize: function (a) {
        this.expression = a.strip();
        if (this.shouldUseSelectorsAPI()) {
            this.mode = "selectorsAPI"
        } else {
            if (this.shouldUseXPath()) {
                this.mode = "xpath";
                this.compileXPathMatcher()
            } else {
                this.mode = "normal";
                this.compileMatcher()
            }
        }
    },
    shouldUseXPath: function () {
        if (!Prototype.BrowserFeatures.XPath) {
            return false
        }
        var a = this.expression;
        if (Prototype.Browser.WebKit && (a.include("-of-type") || a.include(":empty"))) {
            return false
        }
        if ((/(\[[\w-]*?:|:checked)/).test(a)) {
            return false
        }
        return true
    },
    shouldUseSelectorsAPI: function () {
        if (!Prototype.BrowserFeatures.SelectorsAPI) {
            return false
        }
        if (!Selector._div) {
            Selector._div = new Element("div")
        }
        try {
            Selector._div.querySelector(this.expression)
        } catch (a) {
            return false
        }
        return true
    },
    compileMatcher: function () {
        var e = this.expression,
            ps = Selector.patterns,
            h = Selector.handlers,
            c = Selector.criteria,
            le, p, m;
        if (Selector._cache[e]) {
            this.matcher = Selector._cache[e];
            return
        }
        this.matcher = ["this.matcher = function(root) {", "var r = root, h = Selector.handlers, c = false, n;"];
        while (e && le != e && (/\S/).test(e)) {
            le = e;
            for (var i in ps) {
                p = ps[i];
                if (m = e.match(p)) {
                    this.matcher.push(Object.isFunction(c[i]) ? c[i](m) : new Template(c[i]).evaluate(m));
                    e = e.replace(m[0], "");
                    break
                }
            }
        }
        this.matcher.push("return h.unique(n);\n}");
        eval(this.matcher.join("\n"));
        Selector._cache[this.expression] = this.matcher
    },
    compileXPathMatcher: function () {
        var g = this.expression,
            h = Selector.patterns,
            c = Selector.xpath,
            f, a;
        if (Selector._cache[g]) {
            this.xpath = Selector._cache[g];
            return
        }
        this.matcher = [".//*"];
        while (g && f != g && (/\S/).test(g)) {
            f = g;
            for (var d in h) {
                if (a = g.match(h[d])) {
                    this.matcher.push(Object.isFunction(c[d]) ? c[d](a) : new Template(c[d]).evaluate(a));
                    g = g.replace(a[0], "");
                    break
                }
            }
        }
        this.xpath = this.matcher.join("");
        Selector._cache[this.expression] = this.xpath
    },
    findElements: function (a) {
        a = a || document;
        var d = this.expression,
            c;
        switch (this.mode) {
        case "selectorsAPI":
            if (a !== document) {
                var f = a.id,
                    g = $(a).identify();
                d = "#" + g + " " + d
            }
            c = $A(a.querySelectorAll(d)).map(Element.extend);
            a.id = f;
            return c;
        case "xpath":
            return document._getElementsByXPath(this.xpath, a);
        default:
            return this.matcher(a)
        }
    },
    match: function (k) {
        this.tokens = [];
        var r = this.expression,
            a = Selector.patterns,
            g = Selector.assertions;
        var c, f, h;
        while (r && c !== r && (/\S/).test(r)) {
            c = r;
            for (var l in a) {
                f = a[l];
                if (h = r.match(f)) {
                    if (g[l]) {
                        this.tokens.push([l, Object.clone(h)]);
                        r = r.replace(h[0], "")
                    } else {
                        return this.findElements(document).include(k)
                    }
                }
            }
        }
        var q = true,
            d, o;
        for (var l = 0, j; j = this.tokens[l]; l++) {
            d = j[0], o = j[1];
            if (!Selector.assertions[d](k, o)) {
                q = false;
                break
            }
        }
        return q
    },
    toString: function () {
        return this.expression
    },
    inspect: function () {
        return "#<Selector:" + this.expression.inspect() + ">"
    }
});
Object.extend(Selector, {
    _cache: {},
    xpath: {
        descendant: "//*",
        child: "/*",
        adjacent: "/following-sibling::*[1]",
        laterSibling: "/following-sibling::*",
        tagName: function (a) {
            if (a[1] == "*") {
                return ""
            }
            return "[local-name()='" + a[1].toLowerCase() + "' or local-name()='" + a[1].toUpperCase() + "']"
        },
        className: "[contains(concat(' ', @class, ' '), ' #{1} ')]",
        id: "[@id='#{1}']",
        attrPresence: function (a) {
            a[1] = a[1].toLowerCase();
            return new Template("[@#{1}]").evaluate(a)
        },
        attr: function (a) {
            a[1] = a[1].toLowerCase();
            a[3] = a[5] || a[6];
            return new Template(Selector.xpath.operators[a[2]]).evaluate(a)
        },
        pseudo: function (a) {
            var c = Selector.xpath.pseudos[a[1]];
            if (!c) {
                return ""
            }
            if (Object.isFunction(c)) {
                return c(a)
            }
            return new Template(Selector.xpath.pseudos[a[1]]).evaluate(a)
        },
        operators: {
            "=": "[@#{1}='#{3}']",
            "!=": "[@#{1}!='#{3}']",
            "^=": "[starts-with(@#{1}, '#{3}')]",
            "$=": "[substring(@#{1}, (string-length(@#{1}) - string-length('#{3}') + 1))='#{3}']",
            "*=": "[contains(@#{1}, '#{3}')]",
            "~=": "[contains(concat(' ', @#{1}, ' '), ' #{3} ')]",
            "|=": "[contains(concat('-', @#{1}, '-'), '-#{3}-')]"
        },
        pseudos: {
            "first-child": "[not(preceding-sibling::*)]",
            "last-child": "[not(following-sibling::*)]",
            "only-child": "[not(preceding-sibling::* or following-sibling::*)]",
            empty: "[count(*) = 0 and (count(text()) = 0)]",
            checked: "[@checked]",
            disabled: "[(@disabled) and (@type!='hidden')]",
            enabled: "[not(@disabled) and (@type!='hidden')]",
            not: function (c) {
                var k = c[6],
                    j = Selector.patterns,
                    a = Selector.xpath,
                    g, d;
                var h = [];
                while (k && g != k && (/\S/).test(k)) {
                    g = k;
                    for (var f in j) {
                        if (c = k.match(j[f])) {
                            d = Object.isFunction(a[f]) ? a[f](c) : new Template(a[f]).evaluate(c);h.push("(" + d.substring(1, d.length - 1) + ")");k = k.replace(c[0], "");
                            break
                        }
                    }
                }
                return "[not(" + h.join(" and ") + ")]"
            },
            "nth-child": function (a) {
                return Selector.xpath.pseudos.nth("(count(./preceding-sibling::*) + 1) ", a)
            },
            "nth-last-child": function (a) {
                return Selector.xpath.pseudos.nth("(count(./following-sibling::*) + 1) ", a)
            },
            "nth-of-type": function (a) {
                return Selector.xpath.pseudos.nth("position() ", a)
            },
            "nth-last-of-type": function (a) {
                return Selector.xpath.pseudos.nth("(last() + 1 - position()) ", a)
            },
            "first-of-type": function (a) {
                a[6] = "1";
                return Selector.xpath.pseudos["nth-of-type"](a)
            },
            "last-of-type": function (a) {
                a[6] = "1";
                return Selector.xpath.pseudos["nth-last-of-type"](a)
            },
            "only-of-type": function (a) {
                var c = Selector.xpath.pseudos;
                return c["first-of-type"](a) + c["last-of-type"](a)
            },
            nth: function (g, e) {
                var h, j = e[6],
                    d;
                if (j == "even") {
                    j = "2n+0"
                }
                if (j == "odd") {
                    j = "2n+1"
                }
                if (h = j.match(/^(\d+)$/)) {
                    return "[" + g + "= " + h[1] + "]"
                }
                if (h = j.match(/^(-?\d*)?n(([+-])(\d+))?/)) {
                    if (h[1] == "-") {
                        h[1] = -1
                    }
                    var f = h[1] ? Number(h[1]) : 1;
                    var c = h[2] ? Number(h[2]) : 0;d = "[((#{fragment} - #{b}) mod #{a} = 0) and ((#{fragment} - #{b}) div #{a} >= 0)]";
                    return new Template(d).evaluate({
                        fragment: g,
                        a: f,
                        b: c
                    })
                }
            }
        }
    },
    criteria: {
        tagName: 'n = h.tagName(n, r, "#{1}", c);      c = false;',
        className: 'n = h.className(n, r, "#{1}", c);    c = false;',
        id: 'n = h.id(n, r, "#{1}", c);           c = false;',
        attrPresence: 'n = h.attrPresence(n, r, "#{1}", c); c = false;',
        attr: function (a) {
            a[3] = (a[5] || a[6]);
            return new Template('n = h.attr(n, r, "#{1}", "#{3}", "#{2}", c); c = false;').evaluate(a)
        },
        pseudo: function (a) {
            if (a[6]) {
                a[6] = a[6].replace(/"/g, '\\"')
            }
            return new Template('n = h.pseudo(n, "#{1}", "#{6}", r, c); c = false;').evaluate(a)
        },
        descendant: 'c = "descendant";',
        child: 'c = "child";',
        adjacent: 'c = "adjacent";',
        laterSibling: 'c = "laterSibling";'
    },
    patterns: {
        laterSibling: /^\s*~\s*/,
        child: /^\s*>\s*/,
        adjacent: /^\s*\+\s*/,
        descendant: /^\s/,
        tagName: /^\s*(\*|[\w\-]+)(\b|$)?/,
        id: /^#([\w\-\*]+)(\b|$)/,
        className: /^\.([\w\-\*]+)(\b|$)/,
        pseudo: /^:((first|last|nth|nth-last|only)(-child|-of-type)|empty|checked|(en|dis)abled|not)(\((.*?)\))?(\b|$|(?=\s|[:+~>]))/,
        attrPresence: /^\[((?:[\w]+:)?[\w]+)\]/,
        attr: /\[((?:[\w-]*:)?[\w-]+)\s*(?:([!^$*~|]?=)\s*((['"])([^\4]*?)\4|([^'"][^\]]*?)))?\]/
    },
    assertions: {
        tagName: function (a, c) {
            return c[1].toUpperCase() == a.tagName.toUpperCase()
        },
        className: function (a, c) {
            return Element.hasClassName(a, c[1])
        },
        id: function (a, c) {
            return a.id === c[1]
        },
        attrPresence: function (a, c) {
            return Element.hasAttribute(a, c[1])
        },
        attr: function (c, d) {
            var a = Element.readAttribute(c, d[1]);
            return a && Selector.operators[d[2]](a, d[5] || d[6])
        }
    },
    handlers: {
        concat: function (d, c) {
            for (var e = 0, f; f = c[e]; e++) {
                d.push(f)
            }
            return d
        },
        mark: function (a) {
            var e = Prototype.emptyFunction;
            for (var c = 0, d; d = a[c]; c++) {
                d._countedByPrototype = e
            }
            return a
        },
        unmark: function (a) {
            for (var c = 0, d; d = a[c]; c++) {
                d._countedByPrototype = undefined
            }
            return a
        },
        index: function (a, e, h) {
            a._countedByPrototype = Prototype.emptyFunction;
            if (e) {
                for (var c = a.childNodes, f = c.length - 1, d = 1; f >= 0; f--) {
                    var g = c[f];
                    if (g.nodeType == 1 && (!h || g._countedByPrototype)) {
                        g.nodeIndex = d++
                    }
                }
            } else {
                for (var f = 0, d = 1, c = a.childNodes; g = c[f]; f++) {
                    if (g.nodeType == 1 && (!h || g._countedByPrototype)) {
                        g.nodeIndex = d++
                    }
                }
            }
        },
        unique: function (c) {
            if (c.length == 0) {
                return c
            }
            var e = [],
                f;
            for (var d = 0, a = c.length; d < a; d++) {
                if (!(f = c[d])._countedByPrototype) {
                    f._countedByPrototype = Prototype.emptyFunction;
                    e.push(Element.extend(f))
                }
            }
            return Selector.handlers.unmark(e)
        },
        descendant: function (a) {
            var e = Selector.handlers;
            for (var d = 0, c = [], f; f = a[d]; d++) {
                e.concat(c, f.getElementsByTagName("*"))
            }
            return c
        },
        child: function (a) {
            var f = Selector.handlers;
            for (var e = 0, d = [], g; g = a[e]; e++) {
                for (var c = 0, k; k = g.childNodes[c]; c++) {
                    if (k.nodeType == 1 && k.tagName != "!") {
                        d.push(k)
                    }
                }
            }
            return d
        },
        adjacent: function (a) {
            for (var d = 0, c = [], f; f = a[d]; d++) {
                var e = this.nextElementSibling(f);
                if (e) {
                    c.push(e)
                }
            }
            return c
        },
        laterSibling: function (a) {
            var e = Selector.handlers;
            for (var d = 0, c = [], f; f = a[d]; d++) {
                e.concat(c, Element.nextSiblings(f))
            }
            return c
        },
        nextElementSibling: function (a) {
            while (a = a.nextSibling) {
                if (a.nodeType == 1) {
                    return a
                }
            }
            return null
        },
        previousElementSibling: function (a) {
            while (a = a.previousSibling) {
                if (a.nodeType == 1) {
                    return a
                }
            }
            return null
        },
        tagName: function (a, k, d, c) {
            var l = d.toUpperCase();
            var f = [],
                j = Selector.handlers;
            if (a) {
                if (c) {
                    if (c == "descendant") {
                        for (var g = 0, e; e = a[g]; g++) {
                            j.concat(f, e.getElementsByTagName(d))
                        }
                        return f
                    } else {
                        a = this[c](a)
                    }
                    if (d == "*") {
                        return a
                    }
                }
                for (var g = 0, e; e = a[g]; g++) {
                    if (e.tagName.toUpperCase() === l) {
                        f.push(e)
                    }
                }
                return f
            } else {
                return k.getElementsByTagName(d)
            }
        },
        id: function (c, a, k, g) {
            var j = $(k),
                e = Selector.handlers;
            if (!j) {
                return []
            }
            if (!c && a == document) {
                return [j]
            }
            if (c) {
                if (g) {
                    if (g == "child") {
                        for (var d = 0, f; f = c[d]; d++) {
                            if (j.parentNode == f) {
                                return [j]
                            }
                        }
                    } else {
                        if (g == "descendant") {
                            for (var d = 0, f; f = c[d]; d++) {
                                if (Element.descendantOf(j, f)) {
                                    return [j]
                                }
                            }
                        } else {
                            if (g == "adjacent") {
                                for (var d = 0, f; f = c[d]; d++) {
                                    if (Selector.handlers.previousElementSibling(j) == f) {
                                        return [j]
                                    }
                                }
                            } else {
                                c = e[g](c)
                            }
                        }
                    }
                }
                for (var d = 0, f; f = c[d]; d++) {
                    if (f == j) {
                        return [j]
                    }
                }
                return []
            }
            return (j && Element.descendantOf(j, a)) ? [j] : []
        },
        className: function (c, a, d, e) {
            if (c && e) {
                c = this[e](c)
            }
            return Selector.handlers.byClassName(c, a, d)
        },
        byClassName: function (d, c, g) {
            if (!d) {
                d = Selector.handlers.descendant([c])
            }
            var j = " " + g + " ";
            for (var f = 0, e = [], h, a; h = d[f]; f++) {
                a = h.className;
                if (a.length == 0) {
                    continue
                }
                if (a == g || (" " + a + " ").include(j)) {
                    e.push(h)
                }
            }
            return e
        },
        attrPresence: function (d, c, a, h) {
            if (!d) {
                d = c.getElementsByTagName("*")
            }
            if (d && h) {
                d = this[h](d)
            }
            var f = [];
            for (var e = 0, g; g = d[e]; e++) {
                if (Element.hasAttribute(g, a)) {
                    f.push(g)
                }
            }
            return f
        },
        attr: function (a, k, j, l, d, c) {
            if (!a) {
                a = k.getElementsByTagName("*")
            }
            if (a && c) {
                a = this[c](a)
            }
            var m = Selector.operators[d],
                g = [];
            for (var f = 0, e; e = a[f]; f++) {
                var h = Element.readAttribute(e, j);
                if (h === null) {
                    continue
                }
                if (m(h, l)) {
                    g.push(e)
                }
            }
            return g
        },
        pseudo: function (c, d, f, a, e) {
            if (c && e) {
                c = this[e](c)
            }
            if (!c) {
                c = a.getElementsByTagName("*")
            }
            return Selector.pseudos[d](c, f, a)
        }
    },
    pseudos: {
        "first-child": function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (Selector.handlers.previousElementSibling(f)) {
                    continue
                }
                d.push(f)
            }
            return d
        },
        "last-child": function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (Selector.handlers.nextElementSibling(f)) {
                    continue
                }
                d.push(f)
            }
            return d
        },
        "only-child": function (c, j, a) {
            var f = Selector.handlers;
            for (var e = 0, d = [], g; g = c[e]; e++) {
                if (!f.previousElementSibling(g) && !f.nextElementSibling(g)) {
                    d.push(g)
                }
            }
            return d
        },
        "nth-child": function (c, d, a) {
            return Selector.pseudos.nth(c, d, a)
        },
        "nth-last-child": function (c, d, a) {
            return Selector.pseudos.nth(c, d, a, true)
        },
        "nth-of-type": function (c, d, a) {
            return Selector.pseudos.nth(c, d, a, false, true)
        },
        "nth-last-of-type": function (c, d, a) {
            return Selector.pseudos.nth(c, d, a, true, true)
        },
        "first-of-type": function (c, d, a) {
            return Selector.pseudos.nth(c, "1", a, false, true)
        },
        "last-of-type": function (c, d, a) {
            return Selector.pseudos.nth(c, "1", a, true, true)
        },
        "only-of-type": function (c, e, a) {
            var d = Selector.pseudos;
            return d["last-of-type"](d["first-of-type"](c, e, a), e, a)
        },
        getIndices: function (d, c, e) {
            if (d == 0) {
                return c > 0 ? [c] : []
            }
            return $R(1, e).inject([], function (a, f) {
                if (0 == (f - c) % d && (f - c) / d >= 0) {
                    a.push(f)
                }
                return a
            })
        },
        nth: function (c, u, w, t, e) {
            if (c.length == 0) {
                return []
            }
            if (u == "even") {
                u = "2n+0"
            }
            if (u == "odd") {
                u = "2n+1"
            }
            var s = Selector.handlers,
                r = [],
                d = [],
                g;
            s.mark(c);
            for (var q = 0, f; f = c[q]; q++) {
                if (!f.parentNode._countedByPrototype) {
                    s.index(f.parentNode, t, e);
                    d.push(f.parentNode)
                }
            }
            if (u.match(/^\d+$/)) {
                u = Number(u);
                for (var q = 0, f; f = c[q]; q++) {
                    if (f.nodeIndex == u) {
                        r.push(f)
                    }
                }
            } else {
                if (g = u.match(/^(-?\d*)?n(([+-])(\d+))?/)) {
                    if (g[1] == "-") {
                        g[1] = -1
                    }
                    var x = g[1] ? Number(g[1]) : 1;
                    var v = g[2] ? Number(g[2]) : 0;
                    var y = Selector.pseudos.getIndices(x, v, c.length);
                    for (var q = 0, f, k = y.length; f = c[q]; q++) {
                        for (var o = 0; o < k; o++) {
                            if (f.nodeIndex == y[o]) {
                                r.push(f)
                            }
                        }
                    }
                }
            }
            s.unmark(c);
            s.unmark(d);
            return r
        },
        empty: function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (f.tagName == "!" || f.firstChild) {
                    continue
                }
                d.push(f)
            }
            return d
        },
        not: function (a, e, l) {
            var j = Selector.handlers,
                o, d;
            var k = new Selector(e).findElements(l);
            j.mark(k);
            for (var g = 0, f = [], c; c = a[g]; g++) {
                if (!c._countedByPrototype) {
                    f.push(c)
                }
            }
            j.unmark(k);
            return f
        },
        enabled: function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (!f.disabled && (!f.type || f.type !== "hidden")) {
                    d.push(f)
                }
            }
            return d
        },
        disabled: function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (f.disabled) {
                    d.push(f)
                }
            }
            return d
        },
        checked: function (c, g, a) {
            for (var e = 0, d = [], f; f = c[e]; e++) {
                if (f.checked) {
                    d.push(f)
                }
            }
            return d
        }
    },
    operators: {
        "=": function (c, a) {
            return c == a
        },
        "!=": function (c, a) {
            return c != a
        },
        "^=": function (c, a) {
            return c == a || c && c.startsWith(a)
        },
        "$=": function (c, a) {
            return c == a || c && c.endsWith(a)
        },
        "*=": function (c, a) {
            return c == a || c && c.include(a)
        },
        "$=": function (c, a) {
            return c.endsWith(a)
        },
        "*=": function (c, a) {
            return c.include(a)
        },
        "~=": function (c, a) {
            return (" " + c + " ").include(" " + a + " ")
        },
        "|=": function (c, a) {
            return ("-" + (c || "").toUpperCase() + "-").include("-" + (a || "").toUpperCase() + "-")
        }
    },
    split: function (c) {
        var a = [];
        c.scan(/(([\w#:.~>+()\s-]+|\*|\[.*?\])+)\s*(,|$)/, function (d) {
            a.push(d[1].strip())
        });
        return a
    },
    matchElements: function (g, j) {
        var f = $$(j),
            e = Selector.handlers;
        e.mark(f);
        for (var d = 0, c = [], a; a = g[d]; d++) {
            if (a._countedByPrototype) {
                c.push(a)
            }
        }
        e.unmark(f);
        return c
    },
    findElement: function (c, d, a) {
        if (Object.isNumber(d)) {
            a = d;
            d = false
        }
        return Selector.matchElements(c, d || "*")[a || 0]
    },
    findChildElements: function (f, j) {
        j = Selector.split(j.join(","));
        var e = [],
            g = Selector.handlers;
        for (var d = 0, c = j.length, a; d < c; d++) {
            a = new Selector(j[d].strip());
            g.concat(e, a.findElements(f))
        }
        return (c > 1) ? g.unique(e) : e
    }
});
if (Prototype.Browser.IE) {
    Object.extend(Selector.handlers, {
        concat: function (d, c) {
            for (var e = 0, f; f = c[e]; e++) {
                if (f.tagName !== "!") {
                    d.push(f)
                }
            }
            return d
        },
        unmark: function (a) {
            for (var c = 0, d; d = a[c]; c++) {
                d.removeAttribute("_countedByPrototype")
            }
            return a
        }
    })
}
function $$() {
    return Selector.findChildElements(document, $A(arguments))
}
var Form = {
    reset: function (a) {
        $(a).reset();
        return a
    },
    serializeElements: function (h, c) {
        if (typeof c != "object") {
            c = {
                hash: !! c
            }
        } else {
            if (Object.isUndefined(c.hash)) {
                c.hash = true
            }
        }
        var d, g, a = false,
            f = c.submit;
        var e = h.inject({}, function (j, k) {
            if (!k.disabled && k.name) {
                d = k.name;
                g = $(k).getValue();
                if (g != null && k.type != "file" && (k.type != "submit" || (!a && f !== false && (!f || d == f) && (a = true)))) {
                    if (d in j) {
                        if (!Object.isArray(j[d])) {
                            j[d] = [j[d]]
                        }
                        j[d].push(g)
                    } else {
                        j[d] = g
                    }
                }
            }
            return j
        });
        return c.hash ? e : Object.toQueryString(e)
    }
};
Form.Methods = {
    serialize: function (c, a) {
        return Form.serializeElements(Form.getElements(c), a)
    },
    getElements: function (a) {
        return $A($(a).getElementsByTagName("*")).inject([], function (c, d) {
            if (Form.Element.Serializers[d.tagName.toLowerCase()]) {
                c.push(Element.extend(d))
            }
            return c
        })
    },
    getInputs: function (h, d, e) {
        h = $(h);
        var a = h.getElementsByTagName("input");
        if (!d && !e) {
            return $A(a).map(Element.extend)
        }
        for (var f = 0, j = [], g = a.length; f < g; f++) {
            var c = a[f];
            if ((d && c.type != d) || (e && c.name != e)) {
                continue
            }
            j.push(Element.extend(c))
        }
        return j
    },
    disable: function (a) {
        a = $(a);
        Form.getElements(a).invoke("disable");
        return a
    },
    enable: function (a) {
        a = $(a);
        Form.getElements(a).invoke("enable");
        return a
    },
    findFirstElement: function (c) {
        var d = $(c).getElements().findAll(function (e) {
            return "hidden" != e.type && !e.disabled
        });
        var a = d.findAll(function (e) {
            return e.hasAttribute("tabIndex") && e.tabIndex >= 0
        }).sortBy(function (e) {
            return e.tabIndex
        }).first();
        return a ? a : d.find(function (e) {
            return ["input", "select", "textarea"].include(e.tagName.toLowerCase())
        })
    },
    focusFirstElement: function (a) {
        a = $(a);
        a.findFirstElement().activate();
        return a
    },
    request: function (c, a) {
        c = $(c), a = Object.clone(a || {});
        var e = a.parameters,
            d = c.readAttribute("action") || "";
        if (d.blank()) {
            d = window.location.href
        }
        a.parameters = c.serialize(true);
        if (e) {
            if (Object.isString(e)) {
                e = e.toQueryParams()
            }
            Object.extend(a.parameters, e)
        }
        if (c.hasAttribute("method") && !a.method) {
            a.method = c.method
        }
        return new Ajax.Request(d, a)
    }
};
Form.Element = {
    focus: function (a) {
        $(a).focus();
        return a
    },
    select: function (a) {
        $(a).select();
        return a
    }
};
Form.Element.Methods = {
    serialize: function (a) {
        a = $(a);
        if (!a.disabled && a.name) {
            var c = a.getValue();
            if (c != undefined) {
                var d = {};
                d[a.name] = c;
                return Object.toQueryString(d)
            }
        }
        return ""
    },
    getValue: function (a) {
        a = $(a);
        var c = a.tagName.toLowerCase();
        return Form.Element.Serializers[c](a)
    },
    setValue: function (a, c) {
        a = $(a);
        var d = a.tagName.toLowerCase();
        Form.Element.Serializers[d](a, c);
        return a
    },
    clear: function (a) {
        $(a).value = "";
        return a
    },
    present: function (a) {
        return $(a).value != ""
    },
    activate: function (a) {
        a = $(a);
        try {
            a.focus();
            if (a.select && (a.tagName.toLowerCase() != "input" || !["button", "reset", "submit"].include(a.type))) {
                a.select()
            }
        } catch (c) {}
        return a
    },
    disable: function (a) {
        a = $(a);
        a.disabled = true;
        return a
    },
    enable: function (a) {
        a = $(a);
        a.disabled = false;
        return a
    }
};
var Field = Form.Element;
var $F = Form.Element.Methods.getValue;
Form.Element.Serializers = {
    input: function (a, c) {
        switch (a.type.toLowerCase()) {
        case "checkbox":
        case "radio":
            return Form.Element.Serializers.inputSelector(a, c);
        default:
            return Form.Element.Serializers.textarea(a, c)
        }
    },
    inputSelector: function (a, c) {
        if (Object.isUndefined(c)) {
            return a.checked ? a.value : null
        } else {
            a.checked = !! c
        }
    },
    textarea: function (a, c) {
        if (Object.isUndefined(c)) {
            return a.value
        } else {
            a.value = c
        }
    },
    select: function (d, g) {
        if (Object.isUndefined(g)) {
            return this[d.type == "select-one" ? "selectOne" : "selectMany"](d)
        } else {
            var c, e, h = !Object.isArray(g);
            for (var a = 0, f = d.length; a < f; a++) {
                c = d.options[a];
                e = this.optionValue(c);
                if (h) {
                    if (e == g) {
                        c.selected = true;
                        return
                    }
                } else {
                    c.selected = g.include(e)
                }
            }
        }
    },
    selectOne: function (c) {
        var a = c.selectedIndex;
        return a >= 0 ? this.optionValue(c.options[a]) : null
    },
    selectMany: function (e) {
        var a, f = e.length;
        if (!f) {
            return null
        }
        for (var d = 0, a = []; d < f; d++) {
            var c = e.options[d];
            if (c.selected) {
                a.push(this.optionValue(c))
            }
        }
        return a
    },
    optionValue: function (a) {
        return Element.extend(a).hasAttribute("value") ? a.value : a.text
    }
};
Abstract.TimedObserver = Class.create(PeriodicalExecuter, {
    initialize: function ($super, a, c, d) {
        $super(d, c);
        this.element = $(a);
        this.lastValue = this.getValue()
    },
    execute: function () {
        var a = this.getValue();
        if (Object.isString(this.lastValue) && Object.isString(a) ? this.lastValue != a : String(this.lastValue) != String(a)) {
            this.callback(this.element, a);
            this.lastValue = a
        }
    }
});
Form.Element.Observer = Class.create(Abstract.TimedObserver, {
    getValue: function () {
        return Form.Element.getValue(this.element)
    }
});
Form.Observer = Class.create(Abstract.TimedObserver, {
    getValue: function () {
        return Form.serialize(this.element)
    }
});
Abstract.EventObserver = Class.create({
    initialize: function (a, c) {
        this.element = $(a);
        this.callback = c;
        this.lastValue = this.getValue();
        if (this.element.tagName.toLowerCase() == "form") {
            this.registerFormCallbacks()
        } else {
            this.registerCallback(this.element)
        }
    },
    onElementEvent: function () {
        var a = this.getValue();
        if (this.lastValue != a) {
            this.callback(this.element, a);
            this.lastValue = a
        }
    },
    registerFormCallbacks: function () {
        Form.getElements(this.element).each(this.registerCallback, this)
    },
    registerCallback: function (a) {
        if (a.type) {
            switch (a.type.toLowerCase()) {
            case "checkbox":
            case "radio":
                Event.observe(a, "click", this.onElementEvent.bind(this));
                break;
            default:
                Event.observe(a, "change", this.onElementEvent.bind(this));
                break
            }
        }
    }
});
Form.Element.EventObserver = Class.create(Abstract.EventObserver, {
    getValue: function () {
        return Form.Element.getValue(this.element)
    }
});
Form.EventObserver = Class.create(Abstract.EventObserver, {
    getValue: function () {
        return Form.serialize(this.element)
    }
});
if (!window.Event) {
    var Event = {}
}
Object.extend(Event, {
    KEY_BACKSPACE: 8,
    KEY_TAB: 9,
    KEY_RETURN: 13,
    KEY_ESC: 27,
    KEY_LEFT: 37,
    KEY_UP: 38,
    KEY_RIGHT: 39,
    KEY_DOWN: 40,
    KEY_DELETE: 46,
    KEY_HOME: 36,
    KEY_END: 35,
    KEY_PAGEUP: 33,
    KEY_PAGEDOWN: 34,
    KEY_INSERT: 45,
    cache: {},
    relatedTarget: function (c) {
        var a;
        switch (c.type) {
        case "mouseover":
            a = c.fromElement;
            break;
        case "mouseout":
            a = c.toElement;
            break;
        default:
            return null
        }
        return Element.extend(a)
    }
});
Event.Methods = (function () {
    var a;
    if (Prototype.Browser.IE) {
        var c = {
            0: 1,
            1: 4,
            2: 2
        };
        a = function (e, d) {
            return e.button == c[d]
        }
    } else {
        if (Prototype.Browser.WebKit) {
            a = function (e, d) {
                switch (d) {
                case 0:
                    return e.which == 1 && !e.metaKey;
                case 1:
                    return e.which == 1 && e.metaKey;
                default:
                    return false
                }
            }
        } else {
            a = function (e, d) {
                return e.which ? (e.which === d + 1) : (e.button === d)
            }
        }
    }
    return {
        isLeftClick: function (d) {
            return a(d, 0)
        },
        isMiddleClick: function (d) {
            return a(d, 1)
        },
        isRightClick: function (d) {
            return a(d, 2)
        },
        element: function (f) {
            f = Event.extend(f);
            var e = f.target,
                d = f.type,
                g = f.currentTarget;
            if (g && g.tagName) {
                if (d === "load" || d === "error" || (d === "click" && g.tagName.toLowerCase() === "input" && g.type === "radio")) {
                    e = g
                }
            }
            if (e.nodeType == Node.TEXT_NODE) {
                e = e.parentNode
            }
            return Element.extend(e)
        },
        findElement: function (e, g) {
            var d = Event.element(e);
            if (!g) {
                return d
            }
            var f = [d].concat(d.ancestors());
            return Selector.findElement(f, g, 0)
        },
        pointer: function (f) {
            var e = document.documentElement,
                d = document.body || {
                    scrollLeft: 0,
                    scrollTop: 0
                };
            return {
                x: f.pageX || (f.clientX + (e.scrollLeft || d.scrollLeft) - (e.clientLeft || 0)),
                y: f.pageY || (f.clientY + (e.scrollTop || d.scrollTop) - (e.clientTop || 0))
            }
        },
        pointerX: function (d) {
            return Event.pointer(d).x
        },
        pointerY: function (d) {
            return Event.pointer(d).y
        },
        stop: function (d) {
            Event.extend(d);
            d.preventDefault();
            d.stopPropagation();
            d.stopped = true
        }
    }
})();
Event.extend = (function () {
    var a = Object.keys(Event.Methods).inject({}, function (c, d) {
        c[d] = Event.Methods[d].methodize();
        return c
    });
    if (Prototype.Browser.IE) {
        Object.extend(a, {
            stopPropagation: function () {
                this.cancelBubble = true
            },
            preventDefault: function () {
                this.returnValue = false
            },
            inspect: function () {
                return "[object Event]"
            }
        });
        return function (c) {
            if (!c) {
                return false
            }
            if (c._extendedByPrototype) {
                return c
            }
            c._extendedByPrototype = Prototype.emptyFunction;
            var d = Event.pointer(c);
            Object.extend(c, {
                target: c.srcElement,
                relatedTarget: Event.relatedTarget(c),
                pageX: d.x,
                pageY: d.y
            });
            return Object.extend(c, a)
        }
    } else {
        Event.prototype = Event.prototype || document.createEvent("HTMLEvents")["__proto__"];
        Object.extend(Event.prototype, a);
        return Prototype.K
    }
})();
Object.extend(Event, (function () {
    var c = Event.cache;

    function d(l) {
        if (l._prototypeEventID) {
            return l._prototypeEventID[0]
        }
        arguments.callee.id = arguments.callee.id || 1;
        return l._prototypeEventID = [++arguments.callee.id]
    }
    function h(l) {
        if (l && l.include(":")) {
            return "dataavailable"
        }
        return l
    }
    function a(l) {
        return c[l] = c[l] || {}
    }
    function g(o, l) {
        var m = a(o);
        return m[l] = m[l] || []
    }
    function j(m, l, o) {
        var s = d(m);
        var r = g(s, l);
        if (r.pluck("handler").include(o)) {
            return false
        }
        var q = function (t) {
            if (!Event || !Event.extend || (t.eventName && t.eventName != l)) {
                return false
            }
            Event.extend(t);
            o.call(m, t)
        };
        q.handler = o;
        r.push(q);
        return q
    }
    function k(q, l, m) {
        var o = g(q, l);
        return o.find(function (r) {
            return r.handler == m
        })
    }
    function e(q, l, m) {
        var o = a(q);
        if (!o[l]) {
            return false
        }
        o[l] = o[l].without(k(q, l, m))
    }
    function f() {
        for (var m in c) {
            for (var l in c[m]) {
                c[m][l] = null
            }
        }
    }
    if (window.attachEvent) {
        window.attachEvent("onunload", f)
    }
    if (Prototype.Browser.WebKit) {
        window.addEventListener("unload", Prototype.emptyFunction, false)
    }
    return {
        observe: function (o, l, q) {
            o = $(o);
            var m = h(l);
            var r = j(o, l, q);
            if (!r) {
                return o
            }
            if (o.addEventListener) {
                o.addEventListener(m, r, false)
            } else {
                o.attachEvent("on" + m, r)
            }
            return o
        },
        stopObserving: function (o, l, q) {
            o = $(o);
            var s = d(o),
                m = h(l);
            if (!q && l) {
                g(s, l).each(function (t) {
                    o.stopObserving(l, t.handler)
                });
                return o
            } else {
                if (!l) {
                    Object.keys(a(s)).each(function (t) {
                        o.stopObserving(t)
                    });
                    return o
                }
            }
            var r = k(s, l, q);
            if (!r) {
                return o
            }
            if (o.removeEventListener) {
                o.removeEventListener(m, r, false)
            } else {
                o.detachEvent("on" + m, r)
            }
            e(s, l, q);
            return o
        },
        fire: function (o, m, l) {
            o = $(o);
            if (o == document && document.createEvent && !o.dispatchEvent) {
                o = document.documentElement
            }
            var q;
            if (document.createEvent) {
                q = document.createEvent("HTMLEvents");
                q.initEvent("dataavailable", true, true)
            } else {
                q = document.createEventObject();
                q.eventType = "ondataavailable"
            }
            q.eventName = m;
            q.memo = l || {};
            if (document.createEvent) {
                o.dispatchEvent(q)
            } else {
                o.fireEvent(q.eventType, q)
            }
            return Event.extend(q)
        }
    }
})());
Object.extend(Event, Event.Methods);
Element.addMethods({
    fire: Event.fire,
    observe: Event.observe,
    stopObserving: Event.stopObserving
});
Object.extend(document, {
    fire: Element.Methods.fire.methodize(),
    observe: Element.Methods.observe.methodize(),
    stopObserving: Element.Methods.stopObserving.methodize(),
    loaded: false
});
(function () {
    var c;

    function a() {
        if (document.loaded) {
            return
        }
        if (c) {
            window.clearInterval(c)
        }
        document.fire("dom:loaded");
        document.loaded = true
    }
    if (document.addEventListener) {
        if (Prototype.Browser.WebKit) {
            c = window.setInterval(function () {
                if (/loaded|complete/.test(document.readyState)) {
                    a()
                }
            }, 0);
            Event.observe(window, "load", a)
        } else {
            document.addEventListener("DOMContentLoaded", a, false)
        }
    } else {
        document.write("<script id=__onDOMContentLoaded defer src=//:><\/script>");
        $("__onDOMContentLoaded").onreadystatechange = function () {
            if (this.readyState == "complete") {
                this.onreadystatechange = null;
                a()
            }
        }
    }
})();
Hash.toQueryString = Object.toQueryString;
var Toggle = {
    display: Element.toggle
};
Element.Methods.childOf = Element.Methods.descendantOf;
var Insertion = {
    Before: function (a, c) {
        return Element.insert(a, {
            before: c
        })
    },
    Top: function (a, c) {
        return Element.insert(a, {
            top: c
        })
    },
    Bottom: function (a, c) {
        return Element.insert(a, {
            bottom: c
        })
    },
    After: function (a, c) {
        return Element.insert(a, {
            after: c
        })
    }
};
var $continue = new Error('"throw $continue" is deprecated, use "return" instead');
var Position = {
    includeScrollOffsets: false,
    prepare: function () {
        this.deltaX = window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft || 0;
        this.deltaY = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0
    },
    within: function (c, a, d) {
        if (this.includeScrollOffsets) {
            return this.withinIncludingScrolloffsets(c, a, d)
        }
        this.xcomp = a;
        this.ycomp = d;
        this.offset = Element.cumulativeOffset(c);
        return (d >= this.offset[1] && d < this.offset[1] + c.offsetHeight && a >= this.offset[0] && a < this.offset[0] + c.offsetWidth)
    },
    withinIncludingScrolloffsets: function (c, a, e) {
        var d = Element.cumulativeScrollOffset(c);
        this.xcomp = a + d[0] - this.deltaX;
        this.ycomp = e + d[1] - this.deltaY;
        this.offset = Element.cumulativeOffset(c);
        return (this.ycomp >= this.offset[1] && this.ycomp < this.offset[1] + c.offsetHeight && this.xcomp >= this.offset[0] && this.xcomp < this.offset[0] + c.offsetWidth)
    },
    overlap: function (c, a) {
        if (!c) {
            return 0
        }
        if (c == "vertical") {
            return ((this.offset[1] + a.offsetHeight) - this.ycomp) / a.offsetHeight
        }
        if (c == "horizontal") {
            return ((this.offset[0] + a.offsetWidth) - this.xcomp) / a.offsetWidth
        }
    },
    cumulativeOffset: Element.Methods.cumulativeOffset,
    positionedOffset: Element.Methods.positionedOffset,
    absolutize: function (a) {
        Position.prepare();
        return Element.absolutize(a)
    },
    relativize: function (a) {
        Position.prepare();
        return Element.relativize(a)
    },
    realOffset: Element.Methods.cumulativeScrollOffset,
    offsetParent: Element.Methods.getOffsetParent,
    page: Element.Methods.viewportOffset,
    clone: function (c, d, a) {
        a = a || {};
        return Element.clonePosition(d, c, a)
    }
};
if (!document.getElementsByClassName) {
    document.getElementsByClassName = function (c) {
        function a(d) {
            return d.blank() ? null : "[contains(concat(' ', @class, ' '), ' " + d + " ')]"
        }
        c.getElementsByClassName = Prototype.BrowserFeatures.XPath ?
        function (d, f) {
            f = f.toString().strip();
            var e = /\s/.test(f) ? $w(f).map(a).join("") : a(f);
            return e ? document._getElementsByXPath(".//*" + e, d) : []
        } : function (f, g) {
            g = g.toString().strip();
            var h = [],
                j = (/\s/.test(g) ? $w(g) : null);
            if (!j && !g) {
                return h
            }
            var d = $(f).getElementsByTagName("*");
            g = " " + g + " ";
            for (var e = 0, l, k; l = d[e]; e++) {
                if (l.className && (k = " " + l.className + " ") && (k.include(g) || (j && j.all(function (m) {
                    return !m.toString().blank() && k.include(" " + m + " ")
                })))) {
                    h.push(Element.extend(l))
                }
            }
            return h
        };
        return function (e, d) {
            return $(d || document.body).getElementsByClassName(e)
        }
    }(Element.Methods)
}
Element.ClassNames = Class.create();
Element.ClassNames.prototype = {
    initialize: function (a) {
        this.element = $(a)
    },
    _each: function (a) {
        this.element.className.split(/\s+/).select(function (c) {
            return c.length > 0
        })._each(a)
    },
    set: function (a) {
        this.element.className = a
    },
    add: function (a) {
        if (this.include(a)) {
            return
        }
        this.set($A(this).concat(a).join(" "))
    },
    remove: function (a) {
        if (!this.include(a)) {
            return
        }
        this.set($A(this).without(a).join(" "))
    },
    toString: function () {
        return $A(this).join(" ")
    }
};
Object.extend(Element.ClassNames.prototype, Enumerable);
Element.addMethods();
if (typeof(Console) === "undefined") {}
function puts(c, a) {
    Console.puts(c, a)
}
function p() {
    Console.p.apply(this, arguments)
}
BiwaScheme.TopEnv = {};
BiwaScheme.CoreEnv = {};
BiwaScheme.Error = Class.create({
    initialize: function (a) {
        this.message = "Error: " + a
    },
    toString: function () {
        return this.message
    }
});
BiwaScheme.Bug = Class.create(Object.extend(new BiwaScheme.Error(), {
    initialize: function (a) {
        this.message = "[BUG] " + a
    }
}));
BiwaScheme.UserError = Class.create(Object.extend(new BiwaScheme.Error(), {
    initialize: function (a) {
        this.message = a
    }
}));
BiwaScheme.Set = Class.create({
    initialize: function () {
        this.arr = [];
        var a;
        for (a = 0; a < arguments.length; a++) {
            this.arr[a] = arguments[a]
        }
    },
    equals: function (c) {
        if (this.arr.length != c.arr.length) {
            return false
        }
        var d = this.arr.clone();
        var a = c.arr.clone();
        d.sort();
        a.sort();
        for (var e = 0; e < this.arr.length; e++) {
            if (d[e] != a[e]) {
                return false
            }
        }
        return true
    },
    set_cons: function (a) {
        var c = new BiwaScheme.Set(a);
        c.arr = this.arr.clone();
        c.arr.push(a);
        return c
    },
    set_union: function () {
        var e = new BiwaScheme.Set();
        e.arr = this.arr.clone();
        for (var a = 0; a < arguments.length; a++) {
            var c = arguments[a];
            if (!c instanceof BiwaScheme.Set) {
                throw new BiwaScheme.Error("set_union: arguments must be a set")
            }
            for (var d = 0; d < c.arr.length; d++) {
                e.add(c.arr[d])
            }
        }
        return e
    },
    set_intersect: function (a) {
        if (!a instanceof BiwaScheme.Set) {
            throw new BiwaScheme.Error("set_intersect: arguments must be a set")
        }
        var d = new BiwaScheme.Set();
        for (var c = 0; c < this.arr.length; c++) {
            if (a.member(this.arr[c])) {
                d.add(this.arr[c])
            }
        }
        return d
    },
    set_minus: function (a) {
        if (!a instanceof BiwaScheme.Set) {
            throw new BiwaScheme.Error("set_minus: arguments must be a set")
        }
        var d = new BiwaScheme.Set();
        for (var c = 0; c < this.arr.length; c++) {
            if (!a.member(this.arr[c])) {
                d.add(this.arr[c])
            }
        }
        return d
    },
    add: function (a) {
        if (!this.member(a)) {
            this.arr.push(a)
        }
    },
    member: function (c) {
        for (var a = 0; a < this.arr.length; a++) {
            if (this.arr[a] == c) {
                return true
            }
        }
        return false
    },
    rindex: function (c) {
        for (var a = this.arr.length - 1; a >= 0; a--) {
            if (this.arr[a] == c) {
                return (this.arr.length - 1 - a)
            }
        }
        return null
    },
    index: function (c) {
        for (var a = 0; a < this.arr.length; a++) {
            if (this.arr[a] == c) {
                return a
            }
        }
        return null
    },
    inspect: function () {
        return "Set(" + this.arr.join(", ") + ")"
    },
    toString: function () {
        return this.inspect()
    },
    size: function () {
        return this.arr.length
    }
});
Function.prototype.to_write = function () {
    return "#<Function " + (this.fname ? this.fname : this.toSource ? this.toSource().truncate(40) : "") + ">"
};
String.prototype.to_write = function () {
    return '"' + this.replace(/\\|\"/g, function (a) {
        return "\\" + a
    }).replace(/\x07/g, "\\a").replace(/\x08/g, "\\b").replace(/\t/g, "\\t").replace(/\n/g, "\\n").replace(/\v/g, "\\v").replace(/\f/g, "\\f").replace(/\r/g, "\\r") + '"'
};
Array.prototype.to_write = function () {
    if (this.closure_p) {
        return "#<Closure>"
    }
    var c = [];
    for (var d = 0; d < this.length; d++) {
        c.push(BiwaScheme.to_write(this[d]))
    }
    return "#(" + c.join(" ") + ")"
};
BiwaScheme.to_write = function (a) {
    if (a === undefined) {
        return "undefined"
    } else {
        if (a === null) {
            return "null"
        } else {
            if (typeof(a.to_write) == "function") {
                return a.to_write()
            } else {
                if (isNaN(a) && typeof(a) == "number") {
                    return "+nan.0"
                } else {
                    switch (a) {
                    case true:
                        return "#t";
                    case false:
                        return "#f";
                    case BiwaScheme.nil:
                        return "()";
                    case Infinity:
                        return "+inf.0";
                    case -Infinity:
                        return "-inf.0"
                    }
                }
            }
        }
    }
    return Object.inspect(a)
};
BiwaScheme.to_display = function (a) {
    if (typeof(a.valueOf()) == "string") {
        return a
    } else {
        if (a instanceof BiwaScheme.Symbol) {
            return a.name
        } else {
            if (a instanceof Array) {
                return "#(" + a.map(BiwaScheme.to_display).join(" ") + ")"
            } else {
                if (a instanceof BiwaScheme.Pair) {
                    return a.inspect(BiwaScheme.to_display)
                } else {
                    if (a instanceof BiwaScheme.Char) {
                        return a.value
                    } else {
                        return BiwaScheme.to_write(a)
                    }
                }
            }
        }
    }
};
BiwaScheme.write_ss = function (f, a) {
    var e = [f],
        d = [false];
    BiwaScheme.find_cyclic(f, e, d);
    var h = BiwaScheme.reduce_cyclic_info(e, d);
    var g = new Array(h.length);
    for (var c = h.length - 1; c >= 0; c--) {
        g[c] = false
    }
    return BiwaScheme.to_write_ss(f, h, g, a)
};
BiwaScheme.to_write_ss = function (g, k, j, c) {
    var e = "";
    var f = k.indexOf(g);
    if (f >= 0) {
        if (j[f]) {
            return "#" + f + "#"
        } else {
            j[f] = true;
            e = "#" + f + "="
        }
    }
    if (g instanceof BiwaScheme.Pair && g != BiwaScheme.nil) {
        var d = [];
        d.push(BiwaScheme.to_write_ss(g.car, k, j, c));
        for (var h = g.cdr; h != BiwaScheme.nil; h = h.cdr) {
            if (!(h instanceof BiwaScheme.Pair) || k.indexOf(h) >= 0) {
                d.push(".");
                d.push(BiwaScheme.to_write_ss(h, k, j, c));
                break
            }
            d.push(BiwaScheme.to_write_ss(h.car, k, j, c))
        }
        e += "(" + d.join(" ") + ")"
    } else {
        if (g instanceof Array) {
            var d = g.map(function (a) {
                return BiwaScheme.to_write_ss(a, k, j, c)
            });
            if (c) {
                e += "[" + d.join(", ") + "]"
            } else {
                e += "#(" + d.join(" ") + ")"
            }
        } else {
            e += BiwaScheme.to_write(g)
        }
    }
    return e
};
BiwaScheme.reduce_cyclic_info = function (e, d) {
    var c = 0;
    for (var a = 0; a < d.length; a++) {
        if (d[a]) {
            e[c] = e[a];
            c++
        }
    }
    return e.slice(0, c)
};
BiwaScheme.find_cyclic = function (e, d, c) {
    var a = (e instanceof BiwaScheme.Pair) ? [e.car, e.cdr] : (e instanceof Array) ? e : null;
    if (!a) {
        return
    }
    a.each(function (g) {
        if (typeof(g) == "number" || typeof(g) == "string" || g === BiwaScheme.undef || g === true || g === false || g === BiwaScheme.nil || g instanceof BiwaScheme.Symbol) {
            return
        }
        var f = d.indexOf(g);
        if (f >= 0) {
            c[f] = true
        } else {
            d.push(g);
            c.push(false);
            BiwaScheme.find_cyclic(g, d, c)
        }
    })
};
BiwaScheme.Pair = Class.create({
    initialize: function (a, c) {
        this.car = a;
        this.cdr = c
    },
    caar: function () {
        return this.car.car
    },
    cadr: function () {
        return this.cdr.car
    },
    cdar: function () {
        return this.cdr.car
    },
    cddr: function () {
        return this.cdr.cdr
    },
    first: function () {
        return this.car
    },
    second: function () {
        return this.cdr.car
    },
    third: function () {
        return this.cdr.cdr.car
    },
    fourth: function () {
        return this.cdr.cdr.cdr.car
    },
    fifth: function () {
        return this.cdr.cdr.cdr.cdr.car
    },
    to_array: function () {
        var a = [];
        for (var c = this; c instanceof BiwaScheme.Pair && c != BiwaScheme.nil; c = c.cdr) {
            a.push(c.car)
        }
        return a
    },
    to_set: function () {
        var c = new BiwaScheme.Set();
        for (var a = this; a instanceof BiwaScheme.Pair && a != BiwaScheme.nil; a = a.cdr) {
            c.add(a.car)
        }
        return c
    },
    length: function () {
        var c = 0;
        for (var a = this; a instanceof BiwaScheme.Pair && a != BiwaScheme.nil; a = a.cdr) {
            c++
        }
        return c
    },
    foreach: function (a) {
        for (var c = this; c instanceof BiwaScheme.Pair && c != BiwaScheme.nil; c = c.cdr) {
            a(c.car)
        }
        return c
    },
    map: function (c) {
        var a = [];
        for (var d = this; BiwaScheme.isPair(d); d = d.cdr) {
            a.push(c(d.car))
        }
        return a
    },
    concat: function (a) {
        var c = this;
        while (c instanceof BiwaScheme.Pair && c.cdr != BiwaScheme.nil) {
            c = c.cdr
        }
        c.cdr = a;
        return this
    },
    inspect: function (e) {
        e || (e = Object.inspect);
        var c = [];
        var d = this.foreach(function (a) {
            c.push(e(a))
        });
        if (d != BiwaScheme.nil) {
            c.push(".");
            c.push(e(d))
        }
        return "(" + c.join(" ") + ")"
    },
    toString: function () {
        return this.inspect()
    },
    to_write: function () {
        return this.inspect(BiwaScheme.to_write)
    }
});
BiwaScheme.List = function () {
    return $A(arguments).to_list()
};
Array.prototype.to_list = function () {
    var c = BiwaScheme.nil;
    for (var a = this.length - 1; a >= 0; a--) {
        c = new BiwaScheme.Pair(this[a], c)
    }
    return c
};
BiwaScheme.Values = Class.create({
    initialize: function (a) {
        this.content = a
    },
    to_write: function () {
        return "#<Values " + this.content.map(BiwaScheme.to_write).join(" ") + ">"
    }
});
BiwaScheme.inner_of_nil = new Object();
BiwaScheme.inner_of_nil.inspect = function () {
    throw new BiwaScheme.Error("cannot take car/cdr of '() in Scheme")
};
BiwaScheme.nil = new BiwaScheme.Pair(BiwaScheme.inner_of_nil, BiwaScheme.inner_of_nil);
BiwaScheme.nil.toString = function () {
    return "nil"
};
BiwaScheme.nil.to_array = function () {
    return []
};
BiwaScheme.undef = new Object();
BiwaScheme.undef.toString = function () {
    return "#<undef>"
};
BiwaScheme.eof = new Object;
BiwaScheme.Symbol = Class.create({
    initialize: function (a) {
        this.name = a;
        BiwaScheme.Symbols[a] = this
    },
    inspect: function () {
        return "'" + this.name
    },
    toString: function () {
        return "'" + this.name
    },
    to_write: function () {
        return this.name
    }
});
BiwaScheme.Symbols = {};
BiwaScheme.Sym = function (a, c) {
    if (BiwaScheme.Symbols[a] === undefined) {
        return new BiwaScheme.Symbol(a)
    } else {
        if (!(BiwaScheme.Symbols[a] instanceof BiwaScheme.Symbol)) {
            return new BiwaScheme.Symbol(a)
        } else {
            return BiwaScheme.Symbols[a]
        }
    }
};
BiwaScheme.gensyms = 0;
BiwaScheme.gensym = function () {
    BiwaScheme.gensyms++;
    return BiwaScheme.Sym("__gensym_" + BiwaScheme.gensyms)
};
BiwaScheme.Char = Class.create({
    initialize: function (a) {
        BiwaScheme.Chars[this.value = a] = this
    },
    to_write: function () {
        switch (this.value) {
        case "\n":
            return "#\\newline";
        case " ":
            return "#\\space";
        case "\t":
            return "#\\tab";
        default:
            return "#\\" + this.value
        }
    },
    inspect: function () {
        return this.to_write()
    }
});
BiwaScheme.Chars = {};
BiwaScheme.Char.get = function (a) {
    if (typeof(a) != "string") {
        throw new BiwaScheme.Bug("Char.get: " + Object.inspect(a) + " is not a string")
    }
    if (BiwaScheme.Chars[a] === undefined) {
        return new BiwaScheme.Char(a)
    } else {
        return BiwaScheme.Chars[a]
    }
};
BiwaScheme.Complex = Class.create({
    initialize: function (c, a) {
        this.real = c;
        this.imag = a
    },
    magnitude: function () {
        return Math.sqrt(this.real * this.real + this.imag * this.imag)
    },
    angle: function () {
        return Math.acos(this.real / this.magnitude())
    }
});
BiwaScheme.Complex.from_polar = function (c, a) {
    var e = c * Math.cos(a);
    var d = c * Math.sin(a);
    return new BiwaScheme.Complex(e, d)
};
BiwaScheme.Complex.assure = function (a) {
    if (a instanceof BiwaScheme.Complex) {
        return a
    } else {
        return new BiwaScheme.Complex(a, 0)
    }
};
BiwaScheme.Rational = Class.create({
    initialize: function (a, c) {
        this.numerator = a;
        this.denominator = c
    }
});
BiwaScheme.Port = Class.create({
    initialize: function (a, c) {
        this.is_open = true;
        this.is_binary = false;
        this.is_input = a;
        this.is_output = c
    },
    close: function () {
        this.is_open = false
    },
    inspect: function () {
        return "#<Port>"
    },
    to_write: function () {
        return "#<Port>"
    }
});
BiwaScheme.Port.BrowserInput = Class.create(BiwaScheme.Port, {
    initialize: function ($super) {
        $super(true, false)
    },
    get_string: function (c) {
        var a = document.createElement("div");
        a.innerHTML = "<input id='webscheme-read-line' type='text'><input id='webscheme-read-line-submit' type='button' value='ok'>";
        $("bs-console").appendChild(a);
        return new BiwaScheme.Pause(function (d) {
            Event.observe($("webscheme-read-line-submit"), "click", function () {
                var e = $("webscheme-read-line").value;
                a.parentNode.removeChild(a);
                puts(e);
                d.resume(c(e))
            })
        })
    }
});
BiwaScheme.Port.DefaultOutput = Class.create(BiwaScheme.Port, {
    initialize: function ($super) {
        $super(false, true)
    },
    put_string: function (a) {
        puts(a, true)
    }
});
BiwaScheme.Port.StringOutput = Class.create(BiwaScheme.Port, {
    initialize: function ($super) {
        this.buffer = [];
        $super(false, true)
    },
    put_string: function (a) {
        this.buffer.push(a)
    },
    output_string: function (a) {
        return this.buffer.join("")
    }
});
BiwaScheme.Port.StringInput = Class.create(BiwaScheme.Port, {
    initialize: function ($super, a) {
        this.str = a;
        $super(true, false)
    },
    get_string: function (a) {
        return a(this.str)
    }
});
BiwaScheme.Port.current_input = new BiwaScheme.Port.BrowserInput();
BiwaScheme.Port.current_output = new BiwaScheme.Port.DefaultOutput();
BiwaScheme.Port.current_error = new BiwaScheme.Port.DefaultOutput();
BiwaScheme.Hashtable = Class.create({
    initialize: function (c, d, a) {
        this.mutable = (a === undefined) ? true : a ? true : false;this.hash_proc = c;this.equiv_proc = d;this.pairs_of = new Hash()
    },
    clear: function () {
        this.pairs_of = new Hash()
    },
    candidate_pairs: function (a) {
        return this.pairs_of.get(a)
    },
    add_pair: function (e, a, d) {
        var c = this.pairs_of.get(e);
        if (c) {
            c.push([a, d])
        } else {
            this.pairs_of.set(e, [
                [a, d]
            ])
        }
    },
    remove_pair: function (d, e) {
        var c = this.pairs_of.get(d);
        var a = c.indexOf(e);
        if (a == -1) {
            throw new BiwaScheme.Bug("Hashtable#remove_pair: pair not found!")
        } else {
            c.splice(a, 1)
        }
    },
    create_copy: function (a) {
        var c = new BiwaScheme.Hashtable(this.hash_proc, this.equiv_proc, a);
        this.pairs_of.each(function (e) {
            var d = e[1].map(function (f) {
                return f.clone()
            });
            c.pairs_of.set(e[0], d)
        });
        return c
    },
    size: function () {
        var a = 0;
        this._apply_pair(function (c) {
            a++
        });
        return a
    },
    keys: function () {
        return this._apply_pair(function (a) {
            return a[0]
        })
    },
    values: function () {
        return this._apply_pair(function (a) {
            return a[1]
        })
    },
    _apply_pair: function (d) {
        var c = [];
        this.pairs_of.values().each(function (a) {
            a.each(function (e) {
                c.push(d(e))
            })
        });
        return c
    },
    to_write: function () {
        return "#<Hashtable size=" + this.size() + ">"
    }
});
BiwaScheme.Hashtable.equal_hash = function (a) {
    return BiwaScheme.to_write(a[0])
};
BiwaScheme.Hashtable.eq_hash = BiwaScheme.Hashtable.equal_hash;
BiwaScheme.Hashtable.eqv_hash = BiwaScheme.Hashtable.equal_hash;
BiwaScheme.Hashtable.string_hash = function (a) {
    return a[0]
};
BiwaScheme.Hashtable.string_ci_hash = function (a) {
    return Object.isString(a[0]) ? a[0].toLowerCase() : a[0]
};
BiwaScheme.Hashtable.symbol_hash = function (a) {
    return (a[0] instanceof BiwaScheme.Symbol) ? a[0].name : a[0]
};
BiwaScheme.Hashtable.eq_equiv = function (a) {
    return BiwaScheme.eq(a[0], a[1])
};
BiwaScheme.Hashtable.eqv_equiv = function (a) {
    return BiwaScheme.eqv(a[0], a[1])
};
BiwaScheme.Syntax = Class.create({
    initialize: function (a, c) {
        this.sname = a;
        this.func = c
    },
    transform: function (a) {
        if (!this.func) {
            throw new BiwaScheme.Bug("sorry, syntax " + this.sname + " is a pseudo syntax now")
        }
        return this.func(a)
    },
    inspect: function () {
        return "#<Syntax " + this.sname + ">"
    }
});
BiwaScheme.TopEnv.define = new BiwaScheme.Syntax("define");
BiwaScheme.TopEnv.begin = new BiwaScheme.Syntax("begin");
BiwaScheme.TopEnv.quote = new BiwaScheme.Syntax("quote");
BiwaScheme.TopEnv.lambda = new BiwaScheme.Syntax("lambda");
BiwaScheme.TopEnv["if"] = new BiwaScheme.Syntax("if");
BiwaScheme.TopEnv["set!"] = new BiwaScheme.Syntax("set!");
BiwaScheme.isNil = function (a) {
    return (a === BiwaScheme.nil)
};
BiwaScheme.isUndef = function (a) {
    return (a === BiwaScheme.undef)
};
BiwaScheme.isChar = function (a) {
    return (a instanceof BiwaScheme.Char)
};
BiwaScheme.isSymbol = function (a) {
    return (a instanceof BiwaScheme.Symbol)
};
BiwaScheme.isPort = function (a) {
    return (a instanceof BiwaScheme.Port)
};
BiwaScheme.isPair = function (a) {
    return (a instanceof BiwaScheme.Pair) && (a !== BiwaScheme.nil)
};
BiwaScheme.isList = function (a) {
    return (a instanceof BiwaScheme.Pair)
};
BiwaScheme.isVector = function (a) {
    return (a instanceof Array) && (a.closure_p !== true)
};
BiwaScheme.isHashtable = function (a) {
    return (a instanceof BiwaScheme.Hashtable)
};
BiwaScheme.isMutableHashtable = function (a) {
    return (a instanceof BiwaScheme.Hashtable) && a.mutable
};
BiwaScheme.isClosure = function (a) {
    return (a instanceof Array) && (a.closure_p === true)
};
BiwaScheme.Parser = Class.create({
    initialize: function (a) {
        this.tokens = this.tokenize(a);
        this.i = 0
    },
    inspect: function () {
        return ["#<Parser:", this.i, "/", this.tokens.length, " ", Object.inspect(this.tokens), ">"].join("")
    },
    tokenize: function (a) {
        var e = new Array(),
            c = null;
        var d = 0;
        while (a != "" && c != a) {
            c = a;
            a = a.replace(/^\s*(;[^\r\n]*(\r|\n|$)|#;|#\||#\\[^\w]|#?(\(|\[|{)|\)|\]|}|\'|`|,@|,|\+inf\.0|-inf\.0|\+nan\.0|\"(\\(.|$)|[^\"\\])*(\"|$)|[^\s()\[\]{}]+)/, function (g, f) {
                var h = f;
                if (h == "#|") {
                    d++;
                    return ""
                } else {
                    if (d > 0) {
                        if (/(.*\|#)/.test(h)) {
                            d--;
                            if (d < 0) {
                                throw new BiwaScheme.Error("Found an extra comment terminator: `|#'")
                            }
                            return h.substring(RegExp.$1.length, h.length)
                        } else {
                            return ""
                        }
                    } else {
                        if (h.charAt(0) != ";") {
                            e[e.length] = h
                        }
                        return ""
                    }
                }
            })
        }
        return e
    },
    sexpCommentMarker: new Object,
    getObject: function () {
        var a = this.getObject0();
        if (a != this.sexpCommentMarker) {
            return a
        }
        a = this.getObject();
        if (a == BiwaScheme.Parser.EOS) {
            throw new BiwaScheme.Error("Readable object not found after S exression comment")
        }
        a = this.getObject();
        return a
    },
    getList: function (f) {
        var c = BiwaScheme.nil,
            a = c;
        while (this.i < this.tokens.length) {
            this.eatObjectsInSexpComment("Input stream terminated unexpectedly(in list)");
            if (this.tokens[this.i] == ")" || this.tokens[this.i] == "]" || this.tokens[this.i] == "}") {
                this.i++;
                break
            }
            if (this.tokens[this.i] == ".") {
                this.i++;
                var e = this.getObject();
                if (e != BiwaScheme.Parser.EOS && c != BiwaScheme.nil) {
                    a.cdr = e
                }
            } else {
                var d = new BiwaScheme.Pair(this.getObject(), BiwaScheme.nil);
                if (c == BiwaScheme.nil) {
                    c = d
                } else {
                    a.cdr = d
                }
                a = d
            }
        }
        return c
    },
    getVector: function (c) {
        var a = new Array();
        while (this.i < this.tokens.length) {
            this.eatObjectsInSexpComment("Input stream terminated unexpectedly(in vector)");
            if (this.tokens[this.i] == ")" || this.tokens[this.i] == "]" || this.tokens[this.i] == "}") {
                this.i++;
                break
            }
            a[a.length] = this.getObject()
        }
        return a
    },
    eatObjectsInSexpComment: function (a) {
        while (this.tokens[this.i] == "#;") {
            this.i++;
            if ((this.getObject() == BiwaScheme.Parser.EOS) || (this.i >= this.tokens.length)) {
                throw new BiwaScheme.Error(a)
            }
        }
    },
    getObject0: function () {
        if (this.i >= this.tokens.length) {
            return BiwaScheme.Parser.EOS
        }
        var a = this.tokens[this.i++];
        if (a == "#;") {
            return this.sexpCommentMarker
        }
        var c = a == "'" ? "quote" : a == "`" ? "quasiquote" : a == "," ? "unquote" : a == ",@" ? "unquote-splicing" : false;
        if (c || a == "(" || a == "#(" || a == "[" || a == "#[" || a == "{" || a == "#{") {
            return c ? new BiwaScheme.Pair(BiwaScheme.Sym(c), new BiwaScheme.Pair(this.getObject(), BiwaScheme.nil)) : (a == "(" || a == "[" || a == "{") ? this.getList(a) : this.getVector(a)
        } else {
            switch (a) {
            case "+inf.0":
                return Infinity;
            case "-inf.0":
                return -Infinity;
            case "+nan.0":
                return NaN
            }
            var d;
            if (/^#x[0-9a-z]+$/i.test(a)) {
                d = new Number("0x" + a.substring(2, a.length))
            } else {
                if (/^#d[0-9\.]+$/i.test(a)) {
                    d = new Number(a.substring(2, a.length))
                } else {
                    d = new Number(a)
                }
            }
            if (!isNaN(d)) {
                return d.valueOf()
            } else {
                if (a == "#f" || a == "#F") {
                    return false
                } else {
                    if (a == "#t" || a == "#T") {
                        return true
                    } else {
                        if (a.toLowerCase() == "#\\newline") {
                            return BiwaScheme.Char.get("\n")
                        } else {
                            if (a.toLowerCase() == "#\\space") {
                                return BiwaScheme.Char.get(" ")
                            } else {
                                if (a.toLowerCase() == "#\\tab") {
                                    return BiwaScheme.Char.get("\t")
                                } else {
                                    if (/^#\\.$/.test(a)) {
                                        return BiwaScheme.Char.get(a.charAt(2))
                                    } else {
                                        if (/^\"(\\(.|$)|[^\"\\])*\"?$/.test(a)) {
                                            return a.replace(/(\r?\n|\\n)/g, "\n").replace(/^\"|\\(.|$)|\"$/g, function (f, e) {
                                                return e ? e : ""
                                            })
                                        } else {
                                            return BiwaScheme.Sym(a)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
});
BiwaScheme.Parser.EOS = new Object();
BiwaScheme.Compiler = Class.create({
    initialize: function () {},
    is_tail: function (a) {
        return (a[0] == "return")
    },
    collect_free: function (h, g, d) {
        var f = h;
        var j = d;
        var a = f.arr;
        for (var c = 0; c < a.length; c++) {
            j = this.compile_refer(a[c], g, ["argument", j])
        }
        return j
    },
    compile_refer: function (a, d, c) {
        return this.compile_lookup(a, d, function (e) {
            return ["refer-local", e, c]
        }, function (e) {
            return ["refer-free", e, c]
        }, function (e) {
            return ["refer-global", e, c]
        })
    },
    compile_lookup: function (a, g, j, k, d) {
        var f = g[0],
            h = g[1];
        if ((n = f.index(a)) != null) {
            return j(n)
        } else {
            if ((n = h.index(a)) != null) {
                return k(n)
            } else {
                var c = a.name;
                return d(c)
            }
        }
    },
    make_boxes: function (f, g, e) {
        var g = g;
        var j = 0;
        var c = [];
        while (g instanceof BiwaScheme.Pair && g != BiwaScheme.nil) {
            if (f.member(g.car)) {
                c.push(j)
            }
            j++;
            g = g.cdr
        }
        var h = e;
        for (var d = c.length - 1; d >= 0; d--) {
            h = ["box", c[d], h]
        }
        return h
    },
    find_sets: function (l, o) {
        var j = null;
        if (l instanceof BiwaScheme.Symbol) {
            j = new BiwaScheme.Set()
        } else {
            if (l instanceof BiwaScheme.Pair) {
                switch (l.first()) {
                case BiwaScheme.Sym("define"):
                    var f = l.third();
                    j = this.find_sets(f, o);
                case BiwaScheme.Sym("begin"):
                    j = this.find_sets(l.cdr, o);
                    break;
                case BiwaScheme.Sym("quote"):
                    j = new BiwaScheme.Set();
                    break;
                case BiwaScheme.Sym("lambda"):
                    var k = l.second(),
                        g = l.cdr.cdr;
                    if (k instanceof BiwaScheme.Pair) {
                        j = this.find_sets(g, o.set_minus(k.to_set()))
                    } else {
                        j = this.find_sets(g, o.set_minus(new BiwaScheme.Set(k)))
                    }
                    break;
                case BiwaScheme.Sym("if"):
                    var q = l.second(),
                        e = l.third(),
                        h = l.fourth();
                    j = this.find_sets(q, o).set_union(this.find_sets(e, o), this.find_sets(h, o));
                    break;
                case BiwaScheme.Sym("set!"):
                    var c = l.second(),
                        a = l.third();
                    if (o.member(c)) {
                        j = this.find_sets(a, o).set_cons(c)
                    } else {
                        j = this.find_sets(a, o)
                    }
                    break;
                case BiwaScheme.Sym("call/cc"):
                    var f = l.second();
                    j = this.find_sets(f, o);
                    break;
                default:
                    var m = new BiwaScheme.Set();
                    for (var d = l; d instanceof BiwaScheme.Pair && d != BiwaScheme.nil; d = d.cdr) {
                        m = m.set_union(this.find_sets(d.car, o))
                    }
                    j = m;
                    break
                }
            } else {
                j = new BiwaScheme.Set()
            }
        }
        if (j == null) {
            throw new BiwaScheme.Bug("find_sets() exited in unusual way")
        } else {
            return j
        }
    },
    find_free: function (o, m, h) {
        var k = null;
        if (o instanceof BiwaScheme.Symbol) {
            if (h.member(o)) {
                k = new BiwaScheme.Set(o)
            } else {
                k = new BiwaScheme.Set()
            }
        } else {
            if (o instanceof BiwaScheme.Pair) {
                switch (o.first()) {
                case BiwaScheme.Sym("define"):
                    var e = o.third();
                    k = this.find_free(e, m, h);
                    break;
                case BiwaScheme.Sym("begin"):
                    k = this.find_free(o.cdr, m, h);
                    break;
                case BiwaScheme.Sym("quote"):
                    k = new BiwaScheme.Set();
                    break;
                case BiwaScheme.Sym("lambda"):
                    var l = o.second(),
                        g = o.cdr.cdr;
                    if (l instanceof BiwaScheme.Pair) {
                        k = this.find_free(g, m.set_union(l.to_set()), h)
                    } else {
                        k = this.find_free(g, m.set_cons(l), h)
                    }
                    break;
                case BiwaScheme.Sym("if"):
                    var r = o.second(),
                        d = o.third(),
                        j = o.fourth();
                    k = this.find_free(r, m, h).set_union(this.find_free(d, m, h), this.find_free(j, m, h));
                    break;
                case BiwaScheme.Sym("set!"):
                    var a = o.second(),
                        e = o.third();
                    if (h.member(a)) {
                        k = this.find_free(e, m, h).set_cons(a)
                    } else {
                        k = this.find_free(e, m, h)
                    }
                    break;
                case BiwaScheme.Sym("call/cc"):
                    var e = o.second();
                    k = this.find_free(e, m, h);
                    break;
                default:
                    var q = new BiwaScheme.Set();
                    for (var c = o; c instanceof BiwaScheme.Pair && c != BiwaScheme.nil; c = c.cdr) {
                        q = q.set_union(this.find_free(c.car, m, h))
                    }
                    k = q;
                    break
                }
            } else {
                k = new BiwaScheme.Set()
            }
        }
        if (k == null) {
            throw new BiwaScheme.Bug("find_free() exited in unusual way")
        } else {
            return k
        }
    },
    find_dot_pos: function (c) {
        var a = 0;
        for (; c instanceof BiwaScheme.Pair && c != BiwaScheme.nil; c = c.cdr, ++a) {}
        if (c != BiwaScheme.nil) {
            return a
        } else {
            return -1
        }
    },
    last_pair: function (a) {
        if (a instanceof BiwaScheme.Pair && a != BiwaScheme.nil) {
            for (; a.cdr instanceof BiwaScheme.Pair && a.cdr != BiwaScheme.nil; a = a.cdr) {}
        }
        return a
    },
    dotted2proper: function (a) {
        var e = function (g) {
            var h = BiwaScheme.nil;
            for (; g instanceof BiwaScheme.Pair && g != BiwaScheme.nil;) {
                var j = g.cdr;
                g.cdr = h;
                h = g;
                g = j
            }
            return h
        };
        var d = function (g) {
            var h = BiwaScheme.nil;
            for (; g instanceof BiwaScheme.Pair && g != BiwaScheme.nil; g = g.cdr) {
                h = new BiwaScheme.Pair(g.car, h)
            }
            return e(h)
        };
        if (a instanceof BiwaScheme.Pair) {
            var f = this.last_pair(a);
            if (f instanceof BiwaScheme.Pair && f.cdr == BiwaScheme.nil) {
                return a
            } else {
                var c = d(a);
                this.last_pair(c).cdr = new BiwaScheme.Pair(f.cdr, BiwaScheme.nil);
                return c
            }
        } else {
            return new BiwaScheme.Pair(a, BiwaScheme.nil)
        }
    },
    compile: function (t, K, C, J, G) {
        var O = null;
        while (1) {
            if (t instanceof BiwaScheme.Symbol) {
                return this.compile_refer(t, K, (C.member(t) ? ["indirect", G] : G))
            } else {
                if (t instanceof BiwaScheme.Pair) {
                    switch (t.first()) {
                    case BiwaScheme.Sym("define"):
                        var j = t.cdr.car;
                        var q = t.cdr.cdr;
                        if (j instanceof BiwaScheme.Symbol) {
                            t = q.car;
                            BiwaScheme.TopEnv[j.name] = BiwaScheme.undef;
                            G = ["assign-global", j.name, G]
                        } else {
                            if (j instanceof BiwaScheme.Pair) {
                                var N = j.car,
                                    h = j.cdr;
                                var z = new BiwaScheme.Pair(BiwaScheme.Sym("lambda"), new BiwaScheme.Pair(h, q));
                                t = z;
                                BiwaScheme.TopEnv[N.name] = BiwaScheme.undef;
                                G = ["assign-global", N.name, G]
                            } else {
                                throw new BiwaScheme.Error("compile: define needs a leftbol or pair: got " + j)
                            }
                        }
                        break;
                    case BiwaScheme.Sym("begin"):
                        var M = [];
                        for (var F = t.cdr; F instanceof BiwaScheme.Pair && F != BiwaScheme.nil; F = F.cdr) {
                            M.push(F.car)
                        }
                        var L = G;
                        for (var I = M.length - 1; I >= 0; I--) {
                            L = this.compile(M[I], K, C, J, L)
                        }
                        return L;
                    case BiwaScheme.Sym("quote"):
                        var A = t.second();
                        return ["constant", A, G];
                    case BiwaScheme.Sym("lambda"):
                        var D = t.cdr.car;
                        var u = new BiwaScheme.Pair(BiwaScheme.Sym("begin"), t.cdr.cdr);
                        var m = this.find_dot_pos(D);
                        var B = this.dotted2proper(D);
                        var y = this.find_free(u, B.to_set(), J);
                        var d = this.find_sets(u, B.to_set());
                        var H = this.compile(u, [B.to_set(), y], d.set_union(C.set_intersect(y)), J.set_union(B.to_set()), ["return"]);
                        var r = ["close", y.size(), this.make_boxes(d, B, H), G, m];
                        return this.collect_free(y, K, r);
                    case BiwaScheme.Sym("if"):
                        var E = t.second(),
                            l = t.third(),
                            o = t.fourth();
                        var l = this.compile(l, K, C, J, G);
                        var o = this.compile(o, K, C, J, G);
                        t = E;
                        G = ["test", l, o];
                        break;
                    case BiwaScheme.Sym("set!"):
                        var w = t.second(),
                            t = t.third();
                        var g = this.compile_lookup(w, K, function (a) {
                            return ["assign-local", a, G]
                        }, function (a) {
                            return ["assign-free", a, G]
                        }, function (a) {
                            return ["assign-global", a, G]
                        });
                        G = g;
                        break;
                    case BiwaScheme.Sym("call/cc"):
                        var t = t.second();
                        var L = ["conti", (this.is_tail(G) ? (K[0].size() + 1) : 0), ["argument", ["constant", 1, ["argument", this.compile(t, K, C, J, (this.is_tail(G) ? ["shift", 1, ["apply"]] : ["apply"]))]]]];
                        return this.is_tail(G) ? L : ["frame", L, G];
                    default:
                        var k = t.car;
                        var h = t.cdr;
                        var L = this.compile(k, K, C, J, this.is_tail(G) ? ["shift", h.length(), ["apply"]] : ["apply"]);L = this.compile(h.length(), K, C, J, ["argument", L]);
                        for (var F = h; F instanceof BiwaScheme.Pair && F != BiwaScheme.nil; F = F.cdr) {
                            L = this.compile(F.car, K, C, J, ["argument", L])
                        }
                        return this.is_tail(G) ? L : ["frame", L, G]
                    }
                } else {
                    return ["constant", t, G]
                }
            }
        }
    },
    run: function (a) {
        return this.compile(a, [new BiwaScheme.Set(), new BiwaScheme.Set()], new BiwaScheme.Set(), new BiwaScheme.Set(), ["halt"])
    }
});
BiwaScheme.Compiler.compile = function (c, a) {
    c = (new BiwaScheme.Interpreter).expand(c);
    return (new BiwaScheme.Compiler).run(c, a)
};
BiwaScheme.Pause = Class.create({
    initialize: function (a) {
        this.on_pause = a
    },
    set_state: function (d, a, g, h, e) {
        this.interpreter = d;
        this.x = a;
        this.f = g;
        this.c = h;
        this.s = e
    },
    ready: function () {
        this.on_pause(this)
    },
    resume: function (a) {
        return this.interpreter.resume(true, a, this.x, this.f, this.c, this.s)
    }
});
BiwaScheme.Call = Class.create({
    initialize: function (a, c, d) {
        this.proc = a;
        this.args = c;
        this.after = d ||
        function (e) {
            return e[0]
        }
    },
    inspect: function () {
        return "#<Call args=" + this.args.inspect() + ">"
    },
    to_write: function () {
        return "#<Call>"
    }
});
BiwaScheme.Iterator = {
    ForArray: Class.create({
        initialize: function (a) {
            this.arr = a;
            this.i = 0
        },
        has_next: function () {
            return this.i < this.arr.length
        },
        next: function () {
            return this.arr[this.i++]
        }
    }),
    ForString: Class.create({
        initialize: function (a) {
            this.str = a;
            this.i = 0
        },
        has_next: function () {
            return this.i < this.str.length
        },
        next: function () {
            return BiwaScheme.Char.get(this.str.charAt(this.i++))
        }
    }),
    ForList: Class.create({
        initialize: function (a) {
            this.ls = a
        },
        has_next: function () {
            return (this.ls instanceof BiwaScheme.Pair) && this.ls != BiwaScheme.nil
        },
        next: function () {
            var a = this.ls;
            this.ls = this.ls.cdr;
            return a
        }
    }),
    ForMulti: Class.create({
        initialize: function (a) {
            this.objs = a;
            this.size = a.length;
            this.iterators = a.map(function (c) {
                return BiwaScheme.Iterator.of(c)
            })
        },
        has_next: function () {
            for (var a = 0; a < this.size; a++) {
                if (!this.iterators[a].has_next()) {
                    return false
                }
            }
            return true
        },
        next: function () {
            return this.iterators.map(function (a) {
                return a.next()
            })
        }
    }),
    of: function (a) {
        switch (true) {
        case (a instanceof Array):
            return new this.ForArray(a);
        case (typeof(a) == "string"):
            return new this.ForString(a);
        case (a instanceof BiwaScheme.Pair):
            return new this.ForList(a);
        default:
            throw new BiwaScheme.Bug("Iterator.of: unknown class: " + Object.inspect(a))
        }
    }
};
BiwaScheme.Call.default_callbacks = {
    call: function (a) {
        return new BiwaScheme.Call(this.proc, [a])
    },
    result: Prototype.emptyFunction,
    finish: Prototype.emptyFunction
};
BiwaScheme.Call.foreach = function (g, f, d) {
    d || (d = false);
    ["call", "result", "finish"].each(function (h) {
        if (!f[h]) {
            f[h] = BiwaScheme.Call.default_callbacks[h]
        }
    });
    var e = null;
    var a = null;
    var c = function (j) {
        if (e) {
            var k = f.result(j[0], a);
            if (k !== undefined) {
                return k
            }
        } else {
            if (d) {
                e = new BiwaScheme.Iterator.ForMulti(g)
            } else {
                e = BiwaScheme.Iterator.of(g)
            }
        }
        if (!e.has_next()) {
            return f.finish()
        } else {
            a = e.next();
            var h = f.call(a);
            h.after = c;
            return h
        }
    };
    return c(null)
};
BiwaScheme.Call.multi_foreach = function (c, a) {
    return BiwaScheme.Call.foreach(c, a, true)
};
BiwaScheme.Interpreter = Class.create({
    initialize: function (a) {
        this.stack = [];
        this.on_error = a ||
        function (c) {};
        this.after_evaluate = Prototype.emptyFunction
    },
    inspect: function () {
        return ["#<Interpreter: stack size=>", this.stack.length, " ", "after_evaluate=", Object.inspect(this.after_evaluate), ">"].join("")
    },
    push: function (a, c) {
        this.stack[c] = a;
        return c + 1
    },
    save_stack: function (d) {
        var a = [];
        for (var c = 0; c < d; c++) {
            a[c] = this.stack[c]
        }
        return a
    },
    restore_stack: function (a) {
        var d = a.length;
        for (var c = 0; c < d; c++) {
            this.stack[c] = a[c]
        }
        return d
    },
    continuation: function (c, d) {
        var a = this.push(d, c);
        return this.closure(["refer-local", 0, ["nuate", this.save_stack(a), ["return"]]], 0, null, -1)
    },
    shift_args: function (e, a, d) {
        for (var c = e - 1; c >= -1; c--) {
            this.index_set(d, c + a + 1, this.index(d, c))
        }
        return d - a - 1
    },
    index: function (c, a) {
        return this.stack[c - a - 2]
    },
    index_set: function (d, c, a) {
        this.stack[d - c - 2] = a
    },
    closure: function (a, g, e, f) {
        var c = [];
        c[0] = a;
        for (var d = 0; d < g; d++) {
            c[d + 1] = this.index(e, d - 1)
        }
        c[g + 1] = f;
        c.closure_p = true;
        return c
    },
    execute: function (g, d, l, o, j) {
        var h = null;
        try {
            h = this._execute(g, d, l, o, j)
        } catch (m) {
            var k = {
                a: g,
                x: d,
                f: l,
                c: o,
                s: j,
                stack: this.stack
            };
            return this.on_error(m, k)
        }
        return h
    },
    run_dump_hook: function (e, d, k, l, h) {
        var g;
        var j;
        if (this.dumper) {
            g = this.dumper
        } else {
            if (BiwaScheme.Interpreter.dumper) {
                g = BiwaScheme.Interpreter.dumper
            } else {
                return
            }
        }
        if (g) {
            var j = new Hash({
                a: e,
                f: k,
                c: l,
                s: h,
                x: d,
                stack: this.stack
            });
            g.dump(j)
        }
    },
    _execute: function (I, t, E, H, A) {
        var J = null;
        while (true) {
            this.run_dump_hook(I, t, E, H, A);
            switch (t[0]) {
            case "halt":
                return I;
            case "refer-local":
                var B = t[1],
                    t = t[2];
                I = this.index(E, B);
                break;
            case "refer-free":
                var B = t[1],
                    t = t[2];
                I = H[B + 1];
                break;
            case "refer-global":
                var y = t[1],
                    t = t[2];
                if (BiwaScheme.TopEnv.hasOwnProperty(y)) {
                    var K = BiwaScheme.TopEnv[y]
                } else {
                    if (BiwaScheme.CoreEnv.hasOwnProperty(y)) {
                        var K = BiwaScheme.CoreEnv[y]
                    } else {
                        throw new BiwaScheme.Error("execute: unbound symbol: " + Object.inspect(y))
                    }
                }
                I = K;
                break;
            case "indirect":
                var t = t[1];
                I = I[0];
                break;
            case "constant":
                var z = t[1],
                    t = t[2];
                I = z;
                break;
            case "close":
                var g = t;
                var B = g[1],
                    w = g[2],
                    t = g[3],
                    k = g[4];
                I = this.closure(w, B, A, k);
                A -= B;
                break;
            case "box":
                var B = t[1],
                    t = t[2];
                this.index_set(A, B, [this.index(A, B)]);
                break;
            case "test":
                var l = t[1],
                    m = t[2];
                t = ((I !== false) ? l : m);
                break;
            case "assign-global":
                var L = t[1],
                    t = t[2];
                if (!BiwaScheme.TopEnv.hasOwnProperty(L) && !BiwaScheme.CoreEnv.hasOwnProperty(L)) {
                    throw new BiwaScheme.Error("global variable '" + L + "' is not defined")
                }
                BiwaScheme.TopEnv[L] = I;
                I = BiwaScheme.undef;
                break;
            case "assign-local":
                var B = t[1],
                    t = t[2];
                var u = this.index(E, B);
                u[0] = I;
                I = BiwaScheme.undef;
                break;
            case "assign-free":
                var B = t[1],
                    t = t[2];
                var u = H[B + 1];
                u[0] = I;
                I = BiwaScheme.undef;
                break;
            case "conti":
                var B = t[1],
                    t = t[2];
                I = this.continuation(A, B);
                break;
            case "nuate":
                var q = t[1],
                    t = t[2];
                A = this.restore_stack(q);
                break;
            case "frame":
                var J = t[2];
                t = t[1];
                A = this.push(J, this.push(E, this.push(H, A)));
                break;
            case "argument":
                var t = t[1];
                A = this.push(I, A);
                break;
            case "shift":
                var B = t[1],
                    t = t[2];
                var e = this.index(A, B);
                A = this.shift_args(B, e, A);
                break;
            case "apply":
                var h = I;
                var e = this.index(A, -1);
                if (h instanceof Array) {
                    I = h;
                    t = h[0];
                    var k = h[h.length - 1];
                    if (k >= 0) {
                        var o = BiwaScheme.nil;
                        for (var D = e; --D >= k;) {
                            o = new BiwaScheme.Pair(this.index(A, D), o)
                        }
                        if (k >= e) {
                            for (var D = -1; D < e; D++) {
                                this.index_set(A, D - 1, this.index(A, D))
                            }
                            A++;
                            this.index_set(A, -1, this.index(A, -1) + 1)
                        }
                        this.index_set(A, k, o)
                    }
                    E = A;
                    H = I
                } else {
                    if (h instanceof Function) {
                        var d = [];
                        for (var D = 0; D < e; D++) {
                            d.push(this.index(A, D))
                        }
                        var v = h(d, this);
                        while ((v instanceof BiwaScheme.Call) && Object.isFunction(v.proc)) {
                            v = v.after([v.proc(v.args, this)])
                        }
                        if (v instanceof BiwaScheme.Pause) {
                            var j = v;
                            j.set_state(this, ["return"], E, H, A);
                            j.ready();
                            return j
                        } else {
                            if (v instanceof BiwaScheme.Call) {
                                var G = ["frame", ["argument", ["constant", 1, ["argument", ["constant", v.after, ["apply"]]]]],
                                    ["return"]
                                ];
                                var r = ["constant", v.args.length, ["argument", ["constant", v.proc, ["apply", v.args.length]]]];
                                var F = v.args.inject(r, function (c, a) {
                                    return ["constant", a, ["argument", c]]
                                });
                                t = ["frame", F, G]
                            } else {
                                I = v;
                                t = ["return"]
                            }
                        }
                    } else {
                        throw new BiwaScheme.Error(Object.inspect(h) + " is not a function")
                    }
                }
                break;
            case "return":
                var B = this.index(A, -1);
                var C = A - B;
                t = this.index(C, 0), E = this.index(C, 1), H = this.index(C, 2), A = C - 3 - 1;
                break;
            default:
                throw new BiwaScheme.Bug("unknown opecode type: " + t[0])
            }
        }
        return I
    },
    expand: function (o, k) {
        k || (k = {});
        var h = null;
        if (o instanceof BiwaScheme.Symbol) {
            h = o
        } else {
            if (o instanceof BiwaScheme.Pair) {
                switch (o.car) {
                case BiwaScheme.Sym("define"):
                    var d = o.cdr.car,
                        e = o.cdr.cdr;
                    h = new BiwaScheme.Pair(BiwaScheme.Sym("define"), new BiwaScheme.Pair(d, this.expand(e, k)));
                    break;
                case BiwaScheme.Sym("begin"):
                    h = new BiwaScheme.Pair(BiwaScheme.Sym("begin"), this.expand(o.cdr, k));
                    break;
                case BiwaScheme.Sym("quote"):
                    h = o;
                    break;
                case BiwaScheme.Sym("lambda"):
                    var j = o.cdr.car,
                        f = o.cdr.cdr;
                    h = new BiwaScheme.Pair(BiwaScheme.Sym("lambda"), new BiwaScheme.Pair(j, this.expand(f, k)));
                    break;
                case BiwaScheme.Sym("if"):
                    var s = o.second(),
                        c = o.third(),
                        g = o.fourth();
                    if (g == BiwaScheme.inner_of_nil) {
                        g = BiwaScheme.undef
                    }
                    h = [BiwaScheme.Sym("if"), this.expand(s, k), this.expand(c, k), this.expand(g, k)].to_list();
                    break;
                case BiwaScheme.Sym("set!"):
                    var r = o.second(),
                        o = o.third();
                    h = [BiwaScheme.Sym("set!"), r, this.expand(o, k)].to_list();
                    break;
                case BiwaScheme.Sym("call-with-current-continuation"):
                case BiwaScheme.Sym("call/cc"):
                    var o = o.second();
                    h = [BiwaScheme.Sym("call/cc"), this.expand(o, k)].to_list();
                    break;
                default:
                    if (o.car instanceof BiwaScheme.Symbol && BiwaScheme.TopEnv[o.car.name] instanceof BiwaScheme.Syntax) {
                        var l = BiwaScheme.TopEnv[o.car.name];
                        k.modified = true;
                        h = l.transform(o);
                        if (BiwaScheme.Debug) {
                            var m = BiwaScheme.to_write(o);
                            var a = BiwaScheme.to_write(h);
                            if (m != a) {
                                puts("expand: " + m + " => " + a)
                            }
                        }
                        var q;
                        for (;;) {
                            h = this.expand(h, q = {});
                            if (!q.modified) {
                                break
                            }
                        }
                    } else {
                        if (o == BiwaScheme.nil) {
                            h = BiwaScheme.nil
                        } else {
                            h = new BiwaScheme.Pair(this.expand(o.car, k), o.cdr.to_array().map(function (t) {
                                return this.expand(t, k)
                            }.bind(this)).to_list())
                        }
                    }
                }
            } else {
                h = o
            }
        }
        return h
    },
    evaluate: function (c, a) {
        this.parser = new BiwaScheme.Parser(c);
        this.compiler = new BiwaScheme.Compiler();
        if (a) {
            this.after_evaluate = a
        }
        if (BiwaScheme.Debug) {
            puts("executing: " + c)
        }
        this.is_top = true;
        this.file_stack = [];
        return this.resume(false)
    },
    resume: function (e, j, k, d, h, o) {
        var g = BiwaScheme.undef;
        for (;;) {
            if (e) {
                g = this.execute(j, k, d, h, o);
                e = false
            } else {
                if (!this.parser) {
                    break
                }
                var l = this.parser.getObject();
                if (l === BiwaScheme.Parser.EOS) {
                    break
                }
                l = this.expand(l);
                var m = this.compiler.run(l);
                g = this.execute(l, m, 0, [], 0)
            }
            if (g instanceof BiwaScheme.Pause) {
                return g
            }
        }
        this.after_evaluate(g);
        return g
    },
    invoke_closure: function (f, d) {
        d || (d = []);
        var c = d.length;
        var a = ["constant", c, ["argument", ["constant", f, ["apply"]]]];
        for (var e = 0; e < c; e++) {
            a = ["constant", d[e],
                ["argument", a]
            ]
        }
        return this.execute(f, ["frame", a, ["halt"]], 0, f, 0)
    },
    compile: function (c) {
        var a = BiwaScheme.Interpreter.read(c);
        var d = BiwaScheme.Compiler.compile(a);
        return d
    }
});
BiwaScheme.Interpreter.read = function (c) {
    var d = new BiwaScheme.Parser(c);
    var a = d.getObject();
    return (a == BiwaScheme.Parser.EOS) ? BiwaScheme.eof : a
};
BiwaScheme.check_arity = function (c, d, a) {
    var e = arguments.callee.caller ? arguments.callee.caller.fname : "";
    if (c < d) {
        if (a && a == d) {
            throw new BiwaScheme.Error(e + ": wrong number of arguments (expected: " + d + " got: " + c + ")")
        } else {
            throw new BiwaScheme.Error(e + ": too few arguments (at least: " + d + " got: " + c + ")")
        }
    } else {
        if (a && a < c) {
            throw new BiwaScheme.Error(e + ": too many arguments (at most: " + a + " got: " + c + ")")
        }
    }
};
BiwaScheme.define_libfunc = function (h, c, a, d, g) {
    var e = function (k, j) {
        BiwaScheme.check_arity(k.length, c, a);
        var f = d(k, j);
        if (g) {
            return f
        } else {
            if (f === undefined) {
                throw new BiwaScheme.Bug("library function `" + h + "' returned JavaScript's undefined")
            } else {
                if (f === null) {
                    throw new BiwaScheme.Bug("library function `" + h + "' returned JavaScript's null")
                } else {
                    return f
                }
            }
        }
    };
    d.fname = h;
    e.fname = h;
    e.inspect = function () {
        return this.fname
    };
    BiwaScheme.CoreEnv[h] = e
};
BiwaScheme.define_libfunc_raw = function (e, c, a, d) {
    BiwaScheme.define_libfunc(e, c, a, d, true)
};
BiwaScheme.define_syntax = function (a, d) {
    var c = new BiwaScheme.Syntax(a, d);
    BiwaScheme.TopEnv[a] = c
};
BiwaScheme.define_scmfunc = function (e, c, a, d) {
    (new Interpreter).evaluate("(define " + e + " " + d + "\n)")
};
var make_assert = function (a) {
    return function () {
        var c = arguments.callee.caller ? arguments.callee.caller.fname : "";a.apply(this, [c].concat($A(arguments)))
    }
};
var make_simple_assert = function (a, c) {
    return make_assert(function (e, d) {
        if (!c(d)) {
            throw new BiwaScheme.Error(e + ": " + a + " required, but got " + BiwaScheme.to_write(d))
        }
    })
};
var assert_number = make_simple_assert("number", function (a) {
    return typeof(a) == "number" || (a instanceof BiwaScheme.Complex)
});
var assert_integer = make_simple_assert("integer", function (a) {
    return typeof(a) == "number" && (a % 1 == 0)
});
var assert_real = make_simple_assert("real number", function (a) {
    return typeof(a) == "number"
});
var assert_between = make_assert(function (e, a, d, c) {
    if (typeof(a) != "number" || a != Math.round(a)) {
        throw new BiwaScheme.Error(e + ": number required, but got " + BiwaScheme.to_write(a))
    }
    if (a < d || c < a) {
        throw new BiwaScheme.Error(e + ": number must be between " + d + " and " + c + ", but got " + BiwaScheme.to_write(a))
    }
});
var assert_string = make_simple_assert("string", Object.isString);
var assert_char = make_simple_assert("character", BiwaScheme.isChar);
var assert_symbol = make_simple_assert("symbol", BiwaScheme.isSymbol);
var assert_port = make_simple_assert("port", BiwaScheme.isPort);
var assert_pair = make_simple_assert("pair", BiwaScheme.isPair);
var assert_list = make_simple_assert("list", BiwaScheme.isList);
var assert_vector = make_simple_assert("vector", BiwaScheme.isVector);
var assert_hashtable = make_simple_assert("hashtable", BiwaScheme.isHashtable);
var assert_mutable_hashtable = make_simple_assert("mutable hashtable", BiwaScheme.isMutableHashtable);
var assert_function = make_simple_assert("JavaScript function", Object.isFunction);
var assert_closure = make_simple_assert("scheme function", BiwaScheme.isClosure);
var assert_applicable = make_simple_assert("scheme/js function", function (a) {
    return BiwaScheme.isClosure(a) || Object.isFunction(a)
});
var assert_date = make_simple_assert("date", function (a) {
    return a instanceof Date
});
var assert = make_assert(function (c, a) {});
if (typeof(BiwaScheme) != "object") {
    BiwaScheme = {}
}
with(BiwaScheme) {
    define_syntax("cond", function (a) {
        var d = a.cdr;
        if (!(d instanceof Pair) || d === nil) {
            throw new Error("malformed cond: cond needs list but got " + to_write_ss(d))
        }
        var c = null;
        d.to_array().reverse().each(function (g) {
            if (!(g instanceof Pair)) {
                throw new Error("bad clause in cond: " + to_write_ss(g))
            }
            if (g.car === Sym("else")) {
                if (c !== null) {
                    throw new Error("'else' clause of cond followed by more clauses: " + to_write_ss(d))
                } else {
                    if (g.cdr === nil) {
                        c = false
                    } else {
                        if (g.cdr.cdr === nil) {
                            c = g.cdr.car
                        } else {
                            c = new Pair(Sym("begin"), g.cdr)
                        }
                    }
                }
            } else {
                if (c === null) {
                    c = BiwaScheme.undef
                } else {
                    var h = g.car;
                    if (g.cdr === nil) {
                        c = [Sym("or"), h, c].to_list()
                    } else {
                        if (g.cdr.cdr === nil) {
                            c = [Sym("if"), h, g.cdr.car, c].to_list()
                        } else {
                            if (g.cdr.car === Sym("=>")) {
                                var h = g.car,
                                    f = g.cdr.cdr.car;
                                var e = BiwaScheme.gensym();
                                c = List(Sym("let"), List(List(e, h)), List(Sym("if"), h, List(f, e), c))
                            } else {
                                c = [Sym("if"), h, new Pair(Sym("begin"), g.cdr), c].to_list()
                            }
                        }
                    }
                }
            }
        });
        return c
    });
    define_syntax("case", function (a) {
        var e = BiwaScheme.gensym();
        if (a.cdr === nil) {
            throw new Error("case: at least one clause is required")
        } else {
            if (!(a.cdr instanceof Pair)) {
                throw new Error("case: proper list is required")
            } else {
                var d = a.cdr.car;
                var f = a.cdr.cdr;
                var c = undefined;
                f.to_array().reverse().each(function (g) {
                    if (g.car === Sym("else")) {
                        if (c === undefined) {
                            c = new Pair(Sym("begin"), g.cdr)
                        } else {
                            throw new Error("case: 'else' clause followed by more clauses: " + to_write_ss(f))
                        }
                    } else {
                        c = [Sym("if"), new Pair(Sym("or"), g.car.to_array().map(function (h) {
                            return [Sym("eqv?"), e, [Sym("quote"), h].to_list()].to_list()
                        }).to_list()), new Pair(Sym("begin"), g.cdr), c].to_list()
                    }
                });
                return new Pair(Sym("let1"), new Pair(e, new Pair(d, new Pair(c, nil))))
            }
        }
    });
    define_syntax("and", function (a) {
        if (a.cdr == nil) {
            return true
        }
        var e = a.cdr.to_array();
        var d = e.length - 1;
        var c = e[d];
        for (d = d - 1; d >= 0; d--) {
            c = [Sym("if"), e[d], c, false].to_list()
        }
        return c
    });
    define_syntax("or", function (a) {
        var e = a.cdr.to_array();
        var d = false;
        for (var c = e.length - 1; c >= 0; c--) {
            d = [Sym("if"), e[c], e[c], d].to_list()
        }
        return d
    });
    define_syntax("let", function (k) {
        var a = null;
        if (k.cdr.car instanceof Symbol) {
            a = k.cdr.car;
            k = k.cdr
        }
        var d = k.cdr.car,
            e = k.cdr.cdr;
        if (!(d instanceof Pair)) {
            throw new Error("let: need a pair for bindings: got " + to_write(d))
        }
        var h = nil,
            j = nil;
        for (var c = d; c instanceof Pair && c != nil; c = c.cdr) {
            h = new Pair(c.car.car, h);
            j = new Pair(c.car.cdr.car, j)
        }
        var g = null;
        if (a) {
            h = h.to_array().reverse().to_list();
            j = j.to_array().reverse().to_list();
            var f = new Pair(Sym("lambda"), new Pair(h, e));
            var l = new Pair(a, j);
            g = [Sym("letrec"), new Pair([a, f].to_list(), nil), l].to_list()
        } else {
            g = new Pair(new Pair(Sym("lambda"), new Pair(h, e)), j)
        }
        return g
    });
    define_syntax("let*", function (c) {
        var e = c.cdr.car,
            a = c.cdr.cdr;
        if (!(e instanceof Pair)) {
            throw new Error("let*: need a pair for bindings: got " + to_write(e))
        }
        var d = null;
        e.to_array().reverse().each(function (f) {
            d = new Pair(Sym("let"), new Pair(new Pair(f, nil), d == null ? a : new Pair(d, nil)))
        });
        return d
    });
    var expand_letrec_star = function (c) {
        var f = c.cdr.car,
            a = c.cdr.cdr;
        if (!(f instanceof Pair)) {
            throw new Error("letrec*: need a pair for bindings: got " + to_write(f))
        }
        var e = a;
        f.to_array().reverse().each(function (g) {
            e = new Pair(new Pair(Sym("set!"), g), e)
        });
        var d = nil;
        f.to_array().reverse().each(function (g) {
            d = new Pair(new Pair(g.car, new Pair(BiwaScheme.undef, nil)), d)
        });
        return new Pair(Sym("let"), new Pair(d, e))
    };
    define_syntax("letrec", expand_letrec_star);
    define_syntax("letrec*", expand_letrec_star);
    define_syntax("let-values", function (c) {
        var g = c.cdr.car;
        var a = c.cdr.cdr;
        var d = null;
        var f = nil;
        var e = nil;
        g.to_array().reverse().each(function (k) {
            var o = k.cdr.car;
            var l = BiwaScheme.gensym();
            var m = new Pair(l, new Pair(new Pair(Sym("lambda"), new Pair(nil, new Pair(o, nil))), nil));
            f = new Pair(m, f);
            var j = k.car;
            e = new Pair(new Pair(j, new Pair(new Pair(l, nil), nil)), e)
        });
        var h = new Pair(Sym("let*-values"), new Pair(e, a));
        d = new Pair(Sym("let"), new Pair(f, new Pair(h, nil)));
        return d
    });
    define_syntax("let*-values", function (c) {
        var e = c.cdr.car;
        var a = c.cdr.cdr;
        var d = null;
        e.to_array().reverse().each(function (g) {
            var f = g.car,
                h = g.cdr.car;
            d = new Pair(Sym("call-with-values"), new Pair(new Pair(Sym("lambda"), new Pair(nil, new Pair(h, nil))), new Pair(new Pair(Sym("lambda"), new Pair(f, (d == null ? a : new Pair(d, nil)))), nil)))
        });
        return d
    });
    BiwaScheme.eq = function (d, c) {
        return d === c
    };
    BiwaScheme.eqv = function (d, c) {
        return d == c && (typeof(d) == typeof(c))
    };
    define_libfunc("eqv?", 2, 2, function (a) {
        return BiwaScheme.eqv(a[0], a[1])
    });
    define_libfunc("eq?", 2, 2, function (a) {
        return BiwaScheme.eq(a[0], a[1])
    });
    define_libfunc("equal?", 2, 2, function (a) {
        return to_write(a[0]) == to_write(a[1])
    });
    define_libfunc("procedure?", 1, 1, function (a) {
        return ((a[0] instanceof Array) && (a[0].closure_p === true) || (typeof a[0] == "function"))
    });
    define_libfunc("number?", 1, 1, function (a) {
        return (typeof(a[0]) == "number") || (a[0] instanceof Complex) || (a[0] instanceof Rational)
    });
    define_libfunc("complex?", 1, 1, function (a) {
        return (a[0] instanceof Complex)
    });
    define_libfunc("real?", 1, 1, function (a) {
        return (typeof(a[0]) == "number")
    });
    define_libfunc("rational?", 1, 1, function (a) {
        return (a[0] instanceof Rational)
    });
    define_libfunc("integer?", 1, 1, function (a) {
        return typeof(a[0]) == "number" && a[0] == Math.round(a[0]) && a[0] != Infinity && a[0] != -Infinity
    });
    define_libfunc("=", 2, null, function (c) {
        var a = c[0];
        assert_number(c[0]);
        for (var d = 1; d < c.length; d++) {
            assert_number(c[d]);
            if (c[d] != a) {
                return false
            }
        }
        return true
    });
    define_libfunc("<", 2, null, function (a) {
        assert_number(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_number(a[c]);
            if (!(a[c - 1] < a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc(">", 2, null, function (a) {
        assert_number(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_number(a[c]);
            if (!(a[c - 1] > a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("<=", 2, null, function (a) {
        assert_number(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_number(a[c]);
            if (!(a[c - 1] <= a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc(">=", 2, null, function (a) {
        assert_number(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_number(a[c]);
            if (!(a[c - 1] >= a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("zero?", 1, 1, function (a) {
        assert_number(a[0]);
        return a[0] === 0
    });
    define_libfunc("positive?", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] > 0)
    });
    define_libfunc("negative?", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] < 0)
    });
    define_libfunc("odd?", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] % 2 == 1) || (a[0] % 2 == -1)
    });
    define_libfunc("even?", 1, 1, function (a) {
        assert_number(a[0]);
        return a[0] % 2 == 0
    });
    define_libfunc("finite?", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] != Infinity) && (a[0] != -Infinity) && !isNaN(a[0])
    });
    define_libfunc("infinite?", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] == Infinity) || (a[0] == -Infinity)
    });
    define_libfunc("nan?", 1, 1, function (a) {
        assert_number(a[0]);
        return isNaN(a[0])
    });
    define_libfunc("max", 2, null, function (a) {
        for (var c = 0; c < a.length; c++) {
            assert_number(a[c])
        }
        return Math.max.apply(null, a)
    });
    define_libfunc("min", 2, null, function (a) {
        for (var c = 0; c < a.length; c++) {
            assert_number(a[c])
        }
        return Math.min.apply(null, a)
    });
    define_libfunc("+", 0, null, function (a) {
        var d = 0;
        for (var c = 0; c < a.length; c++) {
            assert_number(a[c]);
            d += a[c]
        }
        return d
    });
    define_libfunc("*", 0, null, function (a) {
        var d = 1;
        for (var c = 0; c < a.length; c++) {
            assert_number(a[c]);
            d *= a[c]
        }
        return d
    });
    define_libfunc("-", 1, null, function (c) {
        var a = c.length;
        assert_number(c[0]);
        if (a == 1) {
            return -c[0]
        } else {
            var e = c[0];
            for (var d = 1; d < a; d++) {
                assert_number(c[d]);
                e -= c[d]
            }
            return e
        }
    });
    define_libfunc("/", 1, null, function (c) {
        var a = c.length;
        assert_number(c[0]);
        if (a == 1) {
            return 1 / c[0]
        } else {
            var e = c[0];
            for (var d = 1; d < a; d++) {
                assert_number(c[d]);
                e /= c[d]
            }
            return e
        }
    });
    define_libfunc("abs", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.abs(a[0])
    });
    var div = function (c, a) {
        return Math.floor(c / a)
    };
    var mod = function (c, a) {
        return c - Math.floor(c / a) * a
    };
    var div0 = function (c, a) {
        return (c > 0) ? Math.floor(c / a) : Math.ceil(c / a)
    };
    var mod0 = function (c, a) {
        return (c > 0) ? c - Math.floor(c / a) * a : c - Math.ceil(c / a) * a
    };
    define_libfunc("div0-and-mod0", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return new Values([div(a[0], a[1]), mod(a[0], a[1])])
    });
    define_libfunc("div", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return div(a[0], a[1])
    });
    define_libfunc("mod", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return mod(a[0], a[1])
    });
    define_libfunc("div0-and-mod0", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return new Values([div0(a[0], a[1]), mod0(a[0], a[1])])
    });
    define_libfunc("div0", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return div0(a[0], a[1])
    });
    define_libfunc("mod0", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return mod0(a[0], a[1])
    });
    define_libfunc("numerator", 1, 1, function (a) {
        assert_number(a[0]);
        if (a[0] instanceof Rational) {
            return a[0].numerator
        } else {
            throw new Bug("todo")
        }
    });
    define_libfunc("denominator", 1, 1, function (a) {
        assert_number(a[0]);
        if (a[0] instanceof Rational) {
            return a[0].denominator
        } else {
            throw new Bug("todo")
        }
    });
    define_libfunc("floor", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.floor(a[0])
    });
    define_libfunc("ceiling", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.ceil(a[0])
    });
    define_libfunc("truncate", 1, 1, function (a) {
        assert_number(a[0]);
        return (a[0] < 0) ? Math.ceil(a[0]) : Math.floor(a[0])
    });
    define_libfunc("round", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.round(a[0])
    });
    define_libfunc("exp", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.exp(a[0])
    });
    define_libfunc("log", 1, 2, function (a) {
        var c = a[0],
            d = a[1];
        assert_number(c);
        if (d) {
            assert_number(d);
            return Math.log(c) / Math.log(b)
        } else {
            return Math.log(c)
        }
    });
    define_libfunc("sin", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.sin(a[0])
    });
    define_libfunc("cos", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.cos(a[0])
    });
    define_libfunc("tan", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.tan(a[0])
    });
    define_libfunc("asin", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.asin(a[0])
    });
    define_libfunc("acos", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.asos(a[0])
    });
    define_libfunc("atan", 1, 2, function (a) {
        assert_number(a[0]);
        if (a[1]) {
            assert_number(a[1]);
            return Math.atan2(a[0], a[1])
        } else {
            return Math.atan(a[0])
        }
    });
    define_libfunc("sqrt", 1, 1, function (a) {
        assert_number(a[0]);
        return Math.sqrt(a[0])
    });
    define_libfunc("exact-integer-sqrt", 1, 1, function (c) {
        assert_number(c[0]);
        var a = Math.sqrt(c[0]);
        var e = a - (a % 1);
        var d = c[0] - e * e;
        return new Values([e, d])
    });
    define_libfunc("expt", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return Math.pow(a[0], a[1])
    });
    define_libfunc("make-rectangular", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return new Complex(a[0], a[1])
    });
    define_libfunc("make-polar", 2, 2, function (a) {
        assert_number(a[0]);
        assert_number(a[1]);
        return Complex.from_polar(a[0], a[1])
    });
    define_libfunc("real-part", 1, 1, function (a) {
        assert_number(a[0]);
        return Complex.assure(a[0]).real
    });
    define_libfunc("imag-part", 1, 1, function (a) {
        assert_number(a[0]);
        return Complex.assure(a[0]).imag
    });
    define_libfunc("magnitude", 1, 1, function (a) {
        assert_number(a[0]);
        return Complex.assure(a[0]).magnitude()
    });
    define_libfunc("angle", 1, 1, function (a) {
        assert_number(a[0]);
        return Complex.assure(a[0]).angle()
    });
    define_libfunc("number->string", 1, 3, function (c) {
        var e = c[0],
            d = c[1],
            a = c[2];
        if (a) {
            throw new Bug("number->string: presition is not yet implemented")
        }
        d = d || 10;
        return e.toString(d)
    });
    define_libfunc("string->number", 1, 3, function (a) {
        var d = a[0],
            c = a[1] || 10;
        switch (d) {
        case "+inf.0":
            return Infinity;
        case "-inf.0":
            return -Infinity;
        case "+nan.0":
            return NaN;
        default:
            return parseInt(d, c)
        }
    });
    define_libfunc("not", 1, 1, function (a) {
        return (a[0] === false) ? true : false
    });
    define_libfunc("boolean?", 1, 1, function (a) {
        return (a[0] === false || a[0] === true) ? true : false
    });
    define_libfunc("boolean=?", 2, null, function (c) {
        var a = c.length;
        for (var d = 1; d < a; d++) {
            if (c[d] != c[0]) {
                return false
            }
        }
        return true
    });
    define_libfunc("pair?", 1, 1, function (a) {
        return (a[0] instanceof Pair && a[0] != nil) ? true : false
    });
    define_libfunc("cons", 2, 2, function (a) {
        return new Pair(a[0], a[1])
    });
    define_libfunc("car", 1, 1, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("cannot take car of " + a[0])
        }
        return a[0].car
    });
    define_libfunc("cdr", 1, 1, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("cannot take cdr of " + a[0])
        }
        return a[0].cdr
    });
    define_libfunc("set-car!", 2, 2, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("cannot take set-car! of " + a[0])
        }
        a[0].car = a[1];
        return BiwaScheme.undef
    });
    define_libfunc("set-cdr!", 2, 2, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("cannot take set-cdr! of " + a[0])
        }
        a[0].cdr = a[1];
        return BiwaScheme.undef
    });
    define_libfunc("caar", 1, 1, function (a) {
        return a[0].car.car
    });
    define_libfunc("cadr", 1, 1, function (a) {
        return a[0].cdr.car
    });
    define_libfunc("cdar", 1, 1, function (a) {
        return a[0].car.cdr
    });
    define_libfunc("cddr", 1, 1, function (a) {
        return a[0].cdr.cdr
    });
    define_libfunc("caaar", 1, 1, function (a) {
        return a[0].car.car.car
    });
    define_libfunc("caadr", 1, 1, function (a) {
        return a[0].cdr.car.car
    });
    define_libfunc("cadar", 1, 1, function (a) {
        return a[0].car.cdr.car
    });
    define_libfunc("caddr", 1, 1, function (a) {
        return a[0].cdr.cdr.car
    });
    define_libfunc("cdaar", 1, 1, function (a) {
        return a[0].car.car.cdr
    });
    define_libfunc("cdadr", 1, 1, function (a) {
        return a[0].cdr.car.cdr
    });
    define_libfunc("cddar", 1, 1, function (a) {
        return a[0].car.cdr.cdr
    });
    define_libfunc("cdddr", 1, 1, function (a) {
        return a[0].cdr.cdr.cdr
    });
    define_libfunc("caaaar", 1, 1, function (a) {
        return a[0].car.car.car.car
    });
    define_libfunc("caaadr", 1, 1, function (a) {
        return a[0].cdr.car.car.car
    });
    define_libfunc("caadar", 1, 1, function (a) {
        return a[0].car.cdr.car.car
    });
    define_libfunc("caaddr", 1, 1, function (a) {
        return a[0].cdr.cdr.car.car
    });
    define_libfunc("cadaar", 1, 1, function (a) {
        return a[0].car.car.cdr.car
    });
    define_libfunc("cadadr", 1, 1, function (a) {
        return a[0].cdr.car.cdr.car
    });
    define_libfunc("caddar", 1, 1, function (a) {
        return a[0].car.cdr.cdr.car
    });
    define_libfunc("cadddr", 1, 1, function (a) {
        return a[0].cdr.cdr.cdr.car
    });
    define_libfunc("cdaaar", 1, 1, function (a) {
        return a[0].car.car.car.cdr
    });
    define_libfunc("cdaadr", 1, 1, function (a) {
        return a[0].cdr.car.car.cdr
    });
    define_libfunc("cdadar", 1, 1, function (a) {
        return a[0].car.cdr.car.cdr
    });
    define_libfunc("cdaddr", 1, 1, function (a) {
        return a[0].cdr.cdr.car.cdr
    });
    define_libfunc("cddaar", 1, 1, function (a) {
        return a[0].car.car.cdr.cdr
    });
    define_libfunc("cddadr", 1, 1, function (a) {
        return a[0].cdr.car.cdr.cdr
    });
    define_libfunc("cdddar", 1, 1, function (a) {
        return a[0].car.cdr.cdr.cdr
    });
    define_libfunc("cddddr", 1, 1, function (a) {
        return a[0].cdr.cdr.cdr.cdr
    });
    define_libfunc("null?", 1, 1, function (a) {
        return (a[0] === nil)
    });
    define_libfunc("list?", 1, 1, function (a) {
        var c = [];
        for (var d = a[0]; d != nil; d = d.cdr) {
            if (!(d instanceof Pair)) {
                return false
            }
            if (c.find(function (e) {
                return e === d.car
            })) {
                return false
            }
            c.push(d.car)
        }
        return true
    });
    define_libfunc("list", 0, null, function (c) {
        var a = nil;
        for (var d = c.length - 1; d >= 0; d--) {
            a = new Pair(c[d], a)
        }
        return a
    });
    define_libfunc("length", 1, 1, function (a) {
        assert_list(a[0]);
        var d = 0;
        for (var c = a[0]; c != nil; c = c.cdr) {
            d++
        }
        return d
    });
    define_libfunc("append", 2, null, function (c) {
        var a = c.length;
        var d = c[--a];
        while (a--) {
            c[a].to_array().reverse().each(function (e) {
                d = new Pair(e, d)
            })
        }
        return d
    });
    define_libfunc("reverse", 1, 1, function (c) {
        if (!c[0] instanceof Pair) {
            throw new Error("reverse needs pair but got " + c[0])
        }
        var a = nil;
        for (var d = c[0]; d != nil; d = d.cdr) {
            a = new Pair(d.car, a)
        }
        return a
    });
    define_libfunc("list-tail", 2, 2, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("list-tail needs pair but got " + a[0])
        }
        var d = a[0];
        for (var c = 0; c < a[1]; c++) {
            if (!d instanceof Pair) {
                throw new Error("list-tail: the list is shorter than " + a[1])
            }
            d = d.cdr
        }
        return d
    });
    define_libfunc("list-ref", 2, 2, function (a) {
        if (!a[0] instanceof Pair) {
            throw new Error("list-ref needs pair but got " + a[0])
        }
        var d = a[0];
        for (var c = 0; c < a[1]; c++) {
            if (!d instanceof Pair) {
                throw new Error("list-ref: the list is shorter than " + a[1])
            }
            d = d.cdr
        }
        return d.car
    });
    define_libfunc("map", 2, null, function (f) {
        var e = f.shift(),
            c = f;
        c.each(function (a) {
            assert_list(a)
        });
        var d = [];
        return Call.multi_foreach(c, {
            call: function (a) {
                return new Call(e, a.map(function (g) {
                    return g.car
                }))
            },
            result: function (a) {
                d.push(a)
            },
            finish: function () {
                return d.to_list()
            }
        })
    });
    define_libfunc("for-each", 2, null, function (d) {
        var c = d.shift(),
            a = d;
        a.each(function (e) {
            assert_list(e)
        });
        return Call.multi_foreach(a, {
            call: function (e) {
                return new Call(c, e.map(function (f) {
                    return f.car
                }))
            },
            finish: function () {
                return BiwaScheme.undef
            }
        })
    });
    define_libfunc("symbol?", 1, 1, function (a) {
        return (a[0] instanceof Symbol) ? true : false
    });
    define_libfunc("symbol->string", 1, 1, function (a) {
        assert_symbol(a[0]);
        return a[0].name
    });
    define_libfunc("symbol=?", 2, null, function (a) {
        assert_symbol(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_symbol(a[c]);
            if (a[c] != a[0]) {
                return false
            }
        }
        return true
    });
    define_libfunc("string->symbol", 1, 1, function (a) {
        assert_string(a[0]);
        return Sym(a[0])
    });
    define_libfunc("char?", 1, 1, function (a) {
        return (a[0] instanceof Char)
    });
    define_libfunc("char->integer", 1, 1, function (a) {
        assert_char(a[0]);
        return a[0].value.charCodeAt(0)
    });
    define_libfunc("integer->char", 1, 1, function (a) {
        assert_integer(a[0]);
        return Char.get(String.fromCharCode(a[0]))
    });
    var make_char_compare_func = function (a) {
        return function (c) {
            assert_char(c[0]);
            for (var d = 1; d < c.length; d++) {
                assert_char(c[d]);
                if (!a(c[d - 1].value, c[d].value)) {
                    return false
                }
            }
            return true
        }
    };
    define_libfunc("char=?", 2, null, make_char_compare_func(function (d, c) {
        return d == c
    }));
    define_libfunc("char<?", 2, null, make_char_compare_func(function (d, c) {
        return d < c
    }));
    define_libfunc("char>?", 2, null, make_char_compare_func(function (d, c) {
        return d > c
    }));
    define_libfunc("char<=?", 2, null, make_char_compare_func(function (d, c) {
        return d <= c
    }));
    define_libfunc("char>=?", 2, null, make_char_compare_func(function (d, c) {
        return d >= c
    }));
    define_libfunc("string?", 1, 1, function (a) {
        return (typeof(a[0]) == "string")
    });
    define_libfunc("make-string", 1, 2, function (a) {
        assert_integer(a[0]);
        var d = " ";
        if (a[1]) {
            assert_char(a[1]);
            d = a[1].value
        }
        return d.times(a[0])
    });
    define_libfunc("string", 1, null, function (a) {
        for (var c = 0; c < a.length; c++) {
            assert_char(a[c])
        }
        return a.map(function (d) {
            return d.value
        }).join("")
    });
    define_libfunc("string-length", 1, 1, function (a) {
        assert_string(a[0]);
        return a[0].length
    });
    define_libfunc("string-ref", 2, 2, function (a) {
        assert_string(a[0]);
        assert_between(a[1], 0, a[0].length - 1);
        return Char.get(a[0].charAt([a[1]]))
    });
    define_libfunc("string=?", 2, null, function (a) {
        assert_string(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_string(a[c]);
            if (a[0] != a[c]) {
                return false
            }
        }
        return true
    });
    define_libfunc("string<?", 2, null, function (a) {
        assert_string(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_string(a[c]);
            if (!(a[c - 1] < a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("string>?", 2, null, function (a) {
        assert_string(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_string(a[c]);
            if (!(a[c - 1] > a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("string<=?", 2, null, function (a) {
        assert_string(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_string(a[c]);
            if (!(a[c - 1] <= a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("string>=?", 2, null, function (a) {
        assert_string(a[0]);
        for (var c = 1; c < a.length; c++) {
            assert_string(a[c]);
            if (!(a[c - 1] >= a[c])) {
                return false
            }
        }
        return true
    });
    define_libfunc("substring", 3, 3, function (a) {
        assert_string(a[0]);
        assert_integer(a[1]);
        assert_integer(a[2]);
        if (a[1] < 0) {
            throw new Error("substring: start too small: " + a[1])
        }
        if (a[2] < 0) {
            throw new Error("substring: end too small: " + a[2])
        }
        if (a[0].length + 1 <= a[1]) {
            throw new Error("substring: start too big: " + a[1])
        }
        if (a[0].length + 1 <= a[2]) {
            throw new Error("substring: end too big: " + a[2])
        }
        if (!(a[1] <= a[2])) {
            throw new Error("substring: not start <= end: " + a[1] + ", " + a[2])
        }
        return a[0].substring(a[1], a[2])
    });
    define_libfunc("string-append", 0, null, function (a) {
        for (var c = 0; c < a.length; c++) {
            assert_string(a[c])
        }
        return a.join("")
    });
    define_libfunc("string->list", 1, 1, function (a) {
        assert_string(a[0]);
        var c = [];
        a[0].scan(/./, function (d) {
            c.push(Char.get(d[0]))
        });
        return c.to_list()
    });
    define_libfunc("list->string", 1, 1, function (a) {
        assert_list(a[0]);
        return a[0].to_array().map(function (d) {
            return d.value
        }).join("")
    });
    define_libfunc("string-for-each", 2, null, function (c) {
        var a = c.shift(),
            d = c;
        d.each(function (e) {
            assert_string(e)
        });
        return Call.multi_foreach(d, {
            call: function (e) {
                return new Call(a, e)
            },
            finish: function () {
                return BiwaScheme.undef
            }
        })
    });
    define_libfunc("string-copy", 1, 1, function (a) {
        assert_string(a[0]);
        return a[0]
    });
    define_libfunc("vector?", 1, 1, function (a) {
        return (a[0] instanceof Array) && (a[0].closure_p !== true)
    });
    define_libfunc("make-vector", 1, 2, function (a) {
        assert_integer(a[0]);
        var d = new Array(a[0]);
        if (a.length == 2) {
            for (var c = 0; c < a[0]; c++) {
                d[c] = a[1]
            }
        }
        return d
    });
    define_libfunc("vector", 1, null, function (a) {
        return a
    });
    define_libfunc("vector-length", 1, 1, function (a) {
        assert_vector(a[0]);
        return a[0].length
    });
    define_libfunc("vector-ref", 2, 2, function (a) {
        assert_vector(a[0]);
        assert_integer(a[1]);
        return a[0][a[1]]
    });
    define_libfunc("vector-set!", 3, 3, function (a) {
        assert_vector(a[0]);
        assert_integer(a[1]);
        a[0][a[1]] = a[2];
        return BiwaScheme.undef
    });
    define_libfunc("vector->list", 1, 1, function (a) {
        assert_vector(a[0]);
        return a[0].to_list()
    });
    define_libfunc("list->vector", 1, 1, function (a) {
        assert_list(a[0]);
        return a[0].to_array()
    });
    define_libfunc("vector-fill!", 2, 2, function (a) {
        assert_vector(a[0]);
        var d = a[0],
            e = a[1];
        for (var c = 0; c < d.length; c++) {
            d[c] = e
        }
        return d
    });
    define_libfunc("vector-map", 2, null, function (e) {
        var d = e.shift(),
            f = e;
        f.each(function (a) {
            assert_vector(a)
        });
        var c = [];
        return Call.multi_foreach(f, {
            call: function (a) {
                return new Call(d, a)
            },
            result: function (a) {
                c.push(a)
            },
            finish: function () {
                return c
            }
        })
    });
    define_libfunc("vector-for-each", 2, null, function (c) {
        var a = c.shift(),
            d = c;
        d.each(function (e) {
            assert_vector(e)
        });
        return Call.multi_foreach(d, {
            call: function (e) {
                return new Call(a, e)
            },
            finish: function () {
                return BiwaScheme.undef
            }
        })
    });
    define_libfunc("apply", 2, null, function (c) {
        var a = c.shift(),
            e = c.pop(),
            d = c;
        d = d.concat(e.to_array());
        return new Call(a, d)
    });
    define_syntax("call-with-current-continuation", function (a) {
        return new Pair(Sym("call/cc"), a.cdr)
    });
    define_libfunc("values", 0, null, function (a) {
        return new Values(a)
    });
    define_libfunc("call-with-values", 2, 2, function (c) {
        var a = c[0],
            d = c[1];
        return new Call(a, [], function (f) {
            var e = f[0];
            if (!(e instanceof Values)) {
                throw new Error("values expected, but got " + to_write(e))
            }
            return new Call(d, e.content)
        })
    });
    var expand_qq = function (c, d) {
        if (c instanceof Symbol || c === nil) {
            return [Sym("quote"), c].to_list()
        } else {
            if (c instanceof Pair) {
                var a = c.car;
                if (a instanceof Pair && a.car === Sym("unquote-splicing")) {
                    var d = d - 1;
                    if (d == 0) {
                        return [Sym("append"), c.car.cdr.car, expand_qq(c.cdr, d + 1)].to_list()
                    } else {
                        return [Sym("cons"), [Sym("list"), Sym("unquote-splicing"), expand_qq(c.car.cdr.car, d)].to_list(), expand_qq(c.cdr, d + 1)].to_list()
                    }
                } else {
                    if (a === Sym("unquote")) {
                        var d = d - 1;
                        if (d == 0) {
                            return c.cdr.car
                        } else {
                            return [Sym("list"), [Sym("quote"), Sym("unquote")].to_list(), expand_qq(c.cdr.car, d)].to_list()
                        }
                    } else {
                        if (a === Sym("quasiquote")) {
                            return [Sym("list"), Sym("quasiquote"), expand_qq(c.cdr.car, d + 1)].to_list()
                        } else {
                            return [Sym("cons"), expand_qq(c.car, d), expand_qq(c.cdr, d)].to_list()
                        }
                    }
                }
            } else {
                if (c instanceof Array) {
                    throw new Bug("vector quasiquotation is not implemented yet")
                } else {
                    return c
                }
            }
        }
    };
    define_syntax("quasiquote", function (a) {
        return expand_qq(a.cdr.car, 1)
    });
    define_syntax("unquote", function (a) {
        throw new Error("unquote(,) must be inside quasiquote(`)")
    });
    define_syntax("unquote-splicing", function (a) {
        throw new Error("unquote-splicing(,@) must be inside quasiquote(`)")
    });
    define_libfunc("string-upcase", 1, 1, function (a) {
        assert_string(a[0]);
        return a[0].toUpperCase()
    });
    define_libfunc("string-downcase", 1, 1, function (a) {
        assert_string(a[0]);
        return a[0].toLowerCase()
    });
    BiwaScheme.make_string_ci_function = function (a) {
        return function (c) {
            assert_string(c[0]);
            var e = c[0].toUpperCase();
            for (var d = 1; d < c.length; d++) {
                assert_string(c[d]);
                if (!a(e, c[d].toUpperCase())) {
                    return false
                }
            }
            return true
        }
    };
    define_libfunc("string-ci=?", 2, null, make_string_ci_function(function (d, c) {
        return d == c
    }));
    define_libfunc("string-ci<?", 2, null, make_string_ci_function(function (d, c) {
        return d < c
    }));
    define_libfunc("string-ci>?", 2, null, make_string_ci_function(function (d, c) {
        return d > c
    }));
    define_libfunc("string-ci<=?", 2, null, make_string_ci_function(function (d, c) {
        return d <= c
    }));
    define_libfunc("string-ci>=?", 2, null, make_string_ci_function(function (d, c) {
        return d >= c
    }));
    define_libfunc("find", 2, 2, function (d) {
        var c = d[0],
            a = d[1];
        assert_list(a);
        return Call.foreach(a, {
            call: function (e) {
                return new Call(c, [e.car])
            },
            result: function (f, e) {
                if (f) {
                    return e.car
                }
            },
            finish: function () {
                return false
            }
        })
    });
    define_libfunc("for-all", 2, null, function (d) {
        var c = d.shift();
        var a = d;
        a.each(function (f) {
            assert_list(f)
        });
        var e = true;
        return Call.multi_foreach(a, {
            call: function (f) {
                return new Call(c, f.map(function (g) {
                    return g.car
                }))
            },
            result: function (f, g) {
                if (f === false) {
                    return false
                }
                e = f
            },
            finish: function () {
                return e
            }
        })
    });
    define_libfunc("exists", 2, null, function (d) {
        var c = d.shift();
        var a = d;
        a.each(function (e) {
            assert_list(e)
        });
        return Call.multi_foreach(a, {
            call: function (e) {
                return new Call(c, e.map(function (f) {
                    return f.car
                }))
            },
            result: function (e, f) {
                if (e !== false) {
                    return e
                }
            },
            finish: function () {
                return false
            }
        })
    });
    define_libfunc("filter", 2, 2, function (f) {
        var e = f[0],
            d = f[1];
        assert_list(d);
        var c = [];
        return Call.foreach(d, {
            call: function (a) {
                return new Call(e, [a.car])
            },
            result: function (g, a) {
                if (g) {
                    c.push(a.car)
                }
            },
            finish: function () {
                return c.to_list()
            }
        })
    });
    define_libfunc("partition", 2, 2, function (d) {
        var c = d[0],
            a = d[1];
        assert_list(a);
        var e = [],
            g = [];
        return Call.foreach(a, {
            call: function (f) {
                return new Call(c, [f.car])
            },
            result: function (h, f) {
                if (h) {
                    e.push(f.car)
                } else {
                    g.push(f.car)
                }
            },
            finish: function () {
                return new Values([e.to_list(), g.to_list()])
            }
        })
    });
    define_libfunc("fold-left", 3, null, function (e) {
        var c = e.shift(),
            d = e.shift(),
            a = e;
        a.each(function (f) {
            assert_list(f)
        });
        return Call.multi_foreach(a, {
            call: function (g) {
                var f = g.map(function (h) {
                    return h.car
                });
                f.unshift(d);
                return new Call(c, f)
            },
            result: function (f, g) {
                d = f
            },
            finish: function () {
                return d
            }
        })
    });
    define_libfunc("fold-right", 3, null, function (e) {
        var c = e.shift(),
            d = e.shift();
        var a = e.map(function (f) {
            assert_list(f);
            return f.to_array().reverse().to_list()
        });
        return Call.multi_foreach(a, {
            call: function (g) {
                var f = g.map(function (h) {
                    return h.car
                });
                f.push(d);
                return new Call(c, f)
            },
            result: function (f, g) {
                d = f
            },
            finish: function () {
                return d
            }
        })
    });
    define_libfunc("remp", 2, 2, function (d) {
        var c = d[0],
            a = d[1];
        assert_list(a);
        var e = [];
        return Call.foreach(a, {
            call: function (f) {
                return new Call(c, [f.car])
            },
            result: function (g, f) {
                if (!g) {
                    e.push(f.car)
                }
            },
            finish: function () {
                return e.to_list()
            }
        })
    });
    var make_remover = function (a) {
        return function (d) {
            var f = d[0],
                c = d[1];
            assert_list(c);
            var e = [];
            return Call.foreach(c, {
                call: function (g) {
                    return new Call(TopEnv[a] || CoreEnv[a], [f, g.car])
                },
                result: function (h, g) {
                    if (!h) {
                        e.push(g.car)
                    }
                },
                finish: function () {
                    return e.to_list()
                }
            })
        }
    };
    define_libfunc("remove", 2, 2, make_remover("equal?"));
    define_libfunc("remv", 2, 2, make_remover("eqv?"));
    define_libfunc("remq", 2, 2, make_remover("eq?"));
    define_libfunc("memp", 2, 2, function (d) {
        var c = d[0],
            a = d[1];
        assert_list(a);
        var e = [];
        return Call.foreach(a, {
            call: function (f) {
                return new Call(c, [f.car])
            },
            result: function (g, f) {
                if (g) {
                    return f
                }
            },
            finish: function () {
                return false
            }
        })
    });
    var make_finder = function (a) {
        return function (d) {
            var f = d[0],
                c = d[1];
            assert_list(c);
            var e = [];
            return Call.foreach(c, {
                call: function (g) {
                    return new Call(TopEnv[a] || CoreEnv[a], [f, g.car])
                },
                result: function (h, g) {
                    if (h) {
                        return g
                    }
                },
                finish: function () {
                    return false
                }
            })
        }
    };
    define_libfunc("member", 2, 2, make_finder("equal?"));
    define_libfunc("memv", 2, 2, make_finder("eqv?"));
    define_libfunc("memq", 2, 2, make_finder("eq?"));
    define_libfunc("assp", 2, 2, function (c) {
        var a = c[0],
            e = c[1];
        assert_list(e);
        var d = [];
        return Call.foreach(e, {
            call: function (f) {
                if (f.car.car) {
                    return new Call(a, [f.car.car])
                } else {
                    throw new Error("ass*: pair required but got " + to_write(f.car))
                }
            },
            result: function (g, f) {
                if (g) {
                    return f.car
                }
            },
            finish: function () {
                return false
            }
        })
    });
    var make_assoc = function (a) {
        return function (d) {
            var f = d[0],
                c = d[1];
            assert_list(c);
            var e = [];
            return Call.foreach(c, {
                call: function (g) {
                    if (g.car.car) {
                        return new Call(TopEnv[a] || CoreEnv[a], [f, g.car.car])
                    } else {
                        throw new Error("ass*: pair required but got " + to_write(g.car))
                    }
                },
                result: function (h, g) {
                    if (h) {
                        return g.car
                    }
                },
                finish: function () {
                    return false
                }
            })
        }
    };
    define_libfunc("assoc", 2, 2, make_assoc("equal?"));
    define_libfunc("assv", 2, 2, make_assoc("eqv?"));
    define_libfunc("assq", 2, 2, make_assoc("eq?"));
    define_libfunc("cons*", 1, null, function (a) {
        if (a.length == 1) {
            return a[0]
        } else {
            var c = null;
            a.reverse().each(function (d) {
                if (c) {
                    c = new Pair(d, c)
                } else {
                    c = d
                }
            });
            return c
        }
    });
    define_libfunc("list-sort", 1, 2, function (a) {
        if (a[1]) {
            throw new Bug("list-sort: cannot take compare proc now")
        }
        assert_list(a[0]);
        return a[0].to_array().sort().to_list()
    });
    define_libfunc("vector-sort", 1, 2, function (a) {
        if (a[1]) {
            throw new Bug("list-sort: cannot take compare proc now")
        }
        assert_vector(a[0]);
        return a[0].clone().sort()
    });
    define_libfunc("vector-sort!", 1, 2, function (a) {
        if (a[1]) {
            throw new Bug("list-sort: cannot take compare proc now")
        }
        assert_vector(a[0]);
        a[0].sort();
        return BiwaScheme.undef
    });
    define_syntax("when", function (c) {
        var d = c.cdr.car,
            a = c.cdr.cdr;
        return new Pair(Sym("if"), new Pair(d, new Pair(new Pair(Sym("begin"), a), new Pair(BiwaScheme.undef, nil))))
    });
    define_syntax("unless", function (c) {
        var d = c.cdr.car,
            a = c.cdr.cdr;
        return new Pair(Sym("if"), new Pair(new Pair(Sym("not"), new Pair(d, nil)), new Pair(new Pair(Sym("begin"), a), new Pair(BiwaScheme.undef, nil))))
    });
    define_syntax("do", function (h) {
        if (!BiwaScheme.isPair(h.cdr)) {
            throw new Error("do: no variables of do")
        }
        var l = h.cdr.car;
        if (!BiwaScheme.isPair(l)) {
            throw new Error("do: variables must be given as a list")
        }
        if (!BiwaScheme.isPair(h.cdr.cdr)) {
            throw new Error("do: no resulting form of do")
        }
        var a = h.cdr.cdr.car;
        var k = h.cdr.cdr.cdr;
        var d = BiwaScheme.gensym();
        var e = l.map(function (o) {
            var m = o.to_array();
            return List(m[0], m[1])
        }).to_list();
        var f = a.car;
        var g = new Pair(Sym("begin"), a.cdr);
        var c = new Pair(d, l.map(function (o) {
            var m = o.to_array();
            return m[2] || m[0]
        }).to_list());
        var j = new Pair(Sym("begin"), k).concat(List(c));
        return List(Sym("let"), d, e, List(Sym("if"), f, g, j))
    });
    define_syntax("case-lambda", function (a) {});
    define_libfunc("raise", 1, 1, function (a) {
        throw new BiwaScheme.UserError(BiwaScheme.to_write(a[0]))
    });
    define_libfunc("port?", 1, 1, function (a) {
        return (a[0] instanceof Port)
    });
    define_libfunc("textual-port?", 1, 1, function (a) {
        assert_port(a[0]);
        return !a[0].is_binary
    });
    define_libfunc("binary-port?", 1, 1, function (a) {
        assert_port(a[0]);
        return a[0].is_binary
    });
    define_libfunc("close-port", 1, 1, function (a) {
        assert_port(a[0]);
        a[0].close();
        return BiwaScheme.undef
    });
    define_libfunc("call-with-port", 2, 2, function (d) {
        var c = d[0],
            a = d[1];
        assert_port(c);
        assert_closure(a);
        return new Call(a, [c], function (e) {
            c.close();
            return e[0]
        })
    });
    define_libfunc("put-char", 2, 2, function (a) {
        assert_port(a[0]);
        assert_char(a[1]);
        a[0].put_string(a[1].value);
        return BiwaScheme.undef
    });
    define_libfunc("put-string", 2, 2, function (a) {
        assert_port(a[0]);
        assert_string(a[1]);
        a[0].put_string(a[1]);
        return BiwaScheme.undef
    });
    define_libfunc("put-datum", 2, 2, function (a) {
        assert_port(a[0]);
        a[0].put_string(to_write(a[1]));
        return BiwaScheme.undef
    });
    define_libfunc("eof-object", 0, 0, function (a) {
        return eof
    });
    define_libfunc("eof-object?", 1, 1, function (a) {
        return a[0] === eof
    });
    define_libfunc("input-port?", 1, 1, function (a) {
        assert_port(a[0]);
        return a[0].is_input
    });
    define_libfunc("output-port?", 1, 1, function (a) {
        assert_port(a[0]);
        return a[0].is_output
    });
    define_libfunc("current-input-port", 0, 0, function (a) {
        return Port.current_input
    });
    define_libfunc("current-output-port", 0, 0, function (a) {
        return Port.current_output
    });
    define_libfunc("current-error-port", 0, 0, function (a) {
        return Port.current_error
    });
    define_libfunc("close-input-port", 1, 1, function (a) {
        assert_port(a[0]);
        if (!a[0].is_input) {
            throw new Error("close-input-port: port is not input port")
        }
        a[0].close();
        return BiwaScheme.undef
    });
    define_libfunc("close-output-port", 1, 1, function (a) {
        assert_port(a[0]);
        if (!a[0].is_output) {
            throw new Error("close-output-port: port is not output port")
        }
        a[0].close();
        return BiwaScheme.undef
    });
    define_libfunc("read", 0, 1, function (c) {
        var a = c[0] || Port.current_input;
        assert_port(a);
        return a.get_string(function (d) {
            return Interpreter.read(d)
        })
    });
    define_libfunc("newline", 0, 1, function (c) {
        var a = c[0] || Port.current_output;
        a.put_string("\n");
        return BiwaScheme.undef
    });
    define_libfunc("display", 1, 2, function (c) {
        var a = c[1] || Port.current_output;
        a.put_string(to_display(c[0]));
        return BiwaScheme.undef
    });
    define_libfunc("write", 1, 2, function (c) {
        var a = c[1] || Port.current_output;
        assert_port(a);
        a.put_string(to_write(c[0]));
        return BiwaScheme.undef
    });
    define_libfunc("file-exists?", 1, 1, function (c) {
        netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
        assert_string(c[0]);
        var a = FileIO.open(c[0]);
        return a.exists()
    });
    define_libfunc("delete-file", 1, 1, function (c) {
        netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
        assert_string(c[0]);
        var a = FileIO.unlink(FileIO.open(c[0]));
        if (!a) {
            puts("delete-file: cannot delete " + c[0])
        }
        return BiwaScheme.undef
    });
    define_libfunc("make-eq-hashtable", 0, 1, function (a) {
        return new Hashtable(Hashtable.eq_hash, Hashtable.eq_equiv)
    });
    define_libfunc("make-eqv-hashtable", 0, 1, function (a) {
        return new Hashtable(Hashtable.eqv_hash, Hashtable.eqv_equiv)
    });
    define_libfunc("make-hashtable", 2, 3, function (a) {
        assert_applicable(a[0]);
        assert_applicable(a[1]);
        return new Hashtable(a[0], a[1])
    });
    define_libfunc("hashtable?", 1, 1, function (a) {
        return a[0] instanceof Hashtable
    });
    define_libfunc("hashtable-size", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return a[0].keys().length
    });
    BiwaScheme.find_hash_pair = function (d, a, c) {
        return new Call(d.hash_proc, [a], function (e) {
            var g = e[0];
            var f = d.candidate_pairs(g);
            if (!f) {
                return c.on_not_found(g)
            }
            return Call.foreach(f, {
                call: function (h) {
                    return new Call(d.equiv_proc, [a, h[0]])
                },
                result: function (h, j) {
                    if (h) {
                        return c.on_found(j, g)
                    }
                },
                finish: function () {
                    return c.on_not_found(g)
                }
            })
        })
    };
    define_libfunc("hashtable-ref", 3, 3, function (a) {
        var e = a[0],
            c = a[1],
            d = a[2];
        assert_hashtable(e);
        return BiwaScheme.find_hash_pair(e, c, {
            on_found: function (f) {
                return f[1]
            },
            on_not_found: function (f) {
                return d
            }
        })
    });
    define_libfunc("hashtable-set!", 3, 3, function (a) {
        var e = a[0],
            c = a[1],
            d = a[2];
        assert_hashtable(e);
        return BiwaScheme.find_hash_pair(e, c, {
            on_found: function (f) {
                f[1] = d;
                return BiwaScheme.undef
            },
            on_not_found: function (f) {
                e.add_pair(f, c, d);
                return BiwaScheme.undef
            }
        })
    });
    define_libfunc("hashtable-delete!", 2, 2, function (a) {
        var d = a[0],
            c = a[1];
        assert_hashtable(d);
        return BiwaScheme.find_hash_pair(d, c, {
            on_found: function (f, e) {
                d.remove_pair(e, f);
                return BiwaScheme.undef
            },
            on_not_found: function (e) {
                return BiwaScheme.undef
            }
        })
    });
    define_libfunc("hashtable-contains?", 2, 2, function (a) {
        var d = a[0],
            c = a[1];
        assert_hashtable(d);
        return BiwaScheme.find_hash_pair(d, c, {
            on_found: function (e) {
                return true
            },
            on_not_found: function (e) {
                return false
            }
        })
    });
    define_libfunc("hashtable-update!", 4, 4, function (c) {
        var f = c[0],
            d = c[1],
            a = c[2],
            e = c[3];
        assert_hashtable(f);
        assert_applicable(a);
        return BiwaScheme.find_hash_pair(f, d, {
            on_found: function (h, g) {
                return new Call(a, [h[1]], function (j) {
                    h[1] = j[0];
                    return BiwaScheme.undef
                })
            },
            on_not_found: function (g) {
                return new Call(a, [e], function (h) {
                    f.add_pair(g, d, h[0]);
                    return BiwaScheme.undef
                })
            }
        })
    });
    define_libfunc("hashtable-copy", 1, 2, function (c) {
        var a = (c[1] === undefined) ? false : !! c[1];assert_hashtable(c[0]);
        return c[0].create_copy(a)
    });
    define_libfunc("hashtable-clear!", 0, 1, function (a) {
        assert_hashtable(a[0]);
        a[0].clear();
        return BiwaScheme.undef
    });
    define_libfunc("hashtable-keys", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return a[0].keys()
    });
    define_libfunc("hashtable-entries", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return new Values([a[0].keys(), a[0].values()])
    });
    define_libfunc("hashtable-equivalence-function", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return a[0].equiv_proc
    });
    define_libfunc("hashtable-hash-function", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return a[0].hash_proc
    });
    define_libfunc("hashtable-mutable?", 1, 1, function (a) {
        assert_hashtable(a[0]);
        return a[0].mutable
    });
    define_libfunc("equal-hash", 0, 0, function (a) {
        return Hashtable.equal_hash
    });
    define_libfunc("string-hash", 0, 0, function (a) {
        return Hashtable.string_hash
    });
    define_libfunc("string-ci-hash", 0, 0, function (a) {
        return Hashtable.string_ci_hash
    });
    define_libfunc("symbol-hash", 0, 0, function (a) {
        return Hashtable.symbol_hash
    });
    define_libfunc("eval", 1, 1, function (c, a) {
        var d = c[0];
        var a = new BiwaScheme.Interpreter(a.on_error);
        return a.evaluate(d.to_write())
    })
}
if (typeof(BiwaScheme) != "object") {
    BiwaScheme = {}
}
with(BiwaScheme) {
    define_libfunc("read-line", 0, 1, function (c) {
        var a = c[0] || Port.current_input;
        assert_port(a);
        return a.get_string()
    });
    define_libfunc("element-clear!", 1, 1, function (a) {
        return $(a[0]).update()
    });
    define_libfunc("element-empty!", 1, 1, function (a) {
        return $(a[0]).update()
    });
    define_libfunc("element-visible?", 1, 1, function (a) {
        return $(a[0]).visible()
    });
    define_libfunc("element-toggle!", 1, 1, function (a) {
        return $(a[0]).toggle()
    });
    define_libfunc("element-hide!", 1, 1, function (a) {
        return $(a[0]).hide()
    });
    define_libfunc("element-show!", 1, 1, function (a) {
        return $(a[0]).show()
    });
    define_libfunc("element-remove!", 1, 1, function (a) {
        return $(a[0]).remove("")
    });
    define_libfunc("element-update!", 2, 2, function (a) {
        return $(a[0]).update(a[1])
    });
    define_libfunc("element-replace!", 2, 2, function (a) {
        return $(a[0]).replace(a[1])
    });
    define_libfunc("element-insert!", 2, 2, function (a) {
        return $(a[0]).insert(a[1])
    });
    define_libfunc("element-wrap!", 3, 3, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-ancestors", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-descendants", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-first-descendant", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-immediate-descendants", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-previous-sibling", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-next-sibling", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-siblings", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-match?", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-up", 3, 3, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-down", 3, 3, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-previous", 3, 3, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-next", 3, 3, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-select", 0, 0, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-adjacent", 0, 0, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-identify", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-read-attribute", 2, 2, function (a) {
        assert_string(a[1]);
        return $(a[0]).readAttribute(a[1])
    });
    define_libfunc("element-write-attribute", 3, 3, function (a) {
        assert_string(a[1]);
        return $(a[0]).readAttribute(a[1], a[2])
    });
    define_libfunc("element-height", 1, 1, function (a) {
        return $(a[0]).getHeight()
    });
    define_libfunc("element-width", 1, 1, function (a) {
        return $(a[0]).getWidth()
    });
    define_libfunc("element-class-names", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-has-class-name?", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-add-class-name", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-remove-class-name", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-toggle-class-name", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-clean-whitespace!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-empty?", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-descendant-of!", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("scroll-to-element!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-style", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-opacity", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-style-set!", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-opacity-set!", 2, 2, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-dimensions", 1, 1, function (a) {
        var c = $(a[0]).getDimensions();
        return new Values(c.width, c.height)
    });
    define_libfunc("element-make-positioned!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-undo-positioned!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-make-clipping!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-undo-clipping!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-cumulative-offset", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-positioned-offset", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-absolutize!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-relativize!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-cumulative-scroll-offset", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-offset-parent", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-viewport-offset", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-clone-position!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    define_libfunc("element-absolutize!", 1, 1, function (a) {
        throw new Bug("not yet implemented")
    });
    BiwaScheme.create_elements_by_dom = function (c) {
        var a = function (k, j, l) {
            var h = new Element(k, j);
            l.each(function (m) {
                h.insert({
                    bottom: m
                })
            });
            return h
        };
        var c = c.to_array();
        var e = c[0].name || c[0];
        var d = {};
        var g = [];
        for (var f = 1; f < c.length; f++) {
            if (c[f] instanceof Symbol) {
                d[c[f].name] = c[f + 1];
                f++
            } else {
                if (c[f] instanceof Pair) {
                    g.push(create_elements_by_dom(c[f]))
                } else {
                    g.push(c[f].toString())
                }
            }
        }
        return a(e, d, g)
    };
    BiwaScheme.create_elements_by_string = function (a) {
        var a = a.to_array();
        var c = a.shift();
        if (c instanceof Symbol) {
            c = c.name
        }
        if (c.match(/(.*)\.(.*)/)) {
            c = RegExp.$1;
            a.unshift(Sym("class"), RegExp.$2)
        }
        if (c.match(/(.*)\#(.*)/)) {
            c = RegExp.$1;
            a.unshift(Sym("id"), RegExp.$2)
        }
        var e = [];
        var f = ["<" + c];
        for (var d = 0; d < a.length; d++) {
            if (a[d] instanceof Symbol) {
                f.push(" " + a[d].name + '="' + a[d + 1] + '"');
                d++
            } else {
                if (a[d] instanceof Pair) {
                    e.push(create_elements_by_string(a[d]))
                } else {
                    e.push(a[d])
                }
            }
        }
        f.push(">");
        f.push(e.join(""));
        f.push("</" + c + ">");
        return f.join("")
    };
    BiwaScheme.tree_all = function (a, c) {
        if (a === nil) {
            return true
        } else {
            if (c(a.car) === false) {
                return false
            } else {
                return BiwaScheme.tree_all(a.cdr, c)
            }
        }
    };
    define_libfunc("element-new", 1, 1, function (a) {
        var c = function (e) {
            return Object.isString(e) || (e instanceof Symbol) || (e instanceof Pair)
        };
        if (BiwaScheme.tree_all(a[0], c)) {
            var d = new Element("div");
            d.update(create_elements_by_string(a[0]));
            return d.firstChild
        } else {
            return nil
        }
    });
    define_libfunc("element-content", 1, 1, function (a) {
        return a[0].value || (a[0].innerHTML).unescapeHTML()
    });
    define_libfunc("load", 1, 1, function (c, a) {
        var d = c[0];
        assert_string(d);
        return new BiwaScheme.Pause(function (e) {
            new Ajax.Request(d, {
                method: "get",
                evalJSON: false,
                evalJS: false,
                onSuccess: function (g) {
                    var f = new Interpreter(a.on_error);
                    f.evaluate(g.responseText, function () {
                        return e.resume(BiwaScheme.undef)
                    })
                },
                onFailure: function (f) {
                    throw new Error("load: network error: failed to load" + d)
                }
            })
        })
    });
    define_libfunc("js-load", 2, 2, function (c) {
        var d = c[0];
        var a = c[1];
        assert_string(d);
        assert_string(a);
        return new BiwaScheme.Pause(function (e) {
            BiwaScheme.require(d, "window." + a, function () {
                e.resume(BiwaScheme.undef)
            })
        })
    });
    BiwaScheme.getelem = function (c) {
        var a = $(c[0]);
        if (a === undefined || a === null) {
            return false
        } else {
            return a
        }
    };
    define_libfunc("$", 1, 1, BiwaScheme.getelem);
    define_libfunc("getelem", 1, 1, BiwaScheme.getelem);
    define_libfunc("set-style!", 3, 3, function (a) {
        assert_string(a[1]);
        a[0].style[a[1]] = a[2];
        return BiwaScheme.undef
    });
    define_libfunc("get-style", 2, 2, function (a) {
        assert_string(a[1]);
        return a[0].style[a[1]]
    });
    define_libfunc("set-content!", 2, 2, function (a) {
        assert_string(a[1]);
        var c = a[1].replace(/\n/g, "<br>").replace(/\t/g, "&nbsp;&nbsp;&nbsp;");
        a[0].innerHTML = c;
        return BiwaScheme.undef
    });
    define_libfunc("get-content", 1, 1, function (a) {
        return a[0].value || (a[0].innerHTML).unescapeHTML()
    });
    define_libfunc("timer", 2, 2, function (d, c) {
        var a = d[0],
            e = d[1];
        assert_closure(a);
        assert_real(e);
        setTimeout(function () {
            (new Interpreter(c.on_error)).invoke_closure(a)
        }, e * 1000);
        return BiwaScheme.undef
    });
    define_libfunc("set-timer!", 2, 2, function (d, c) {
        var a = d[0],
            e = d[1];
        assert_closure(a);
        assert_real(e);
        return setInterval(function () {
            (new Interpreter(c.on_error)).invoke_closure(a)
        }, e * 1000)
    });
    define_libfunc("clear-timer!", 1, 1, function (a) {
        var c = a[0];
        clearInterval(c);
        return BiwaScheme.undef
    });
    define_libfunc("sleep", 1, 1, function (a) {
        var c = a[0];
        assert_real(c);
        return new BiwaScheme.Pause(function (d) {
            setTimeout(function () {
                d.resume(nil)
            }, c * 1000)
        })
    });
    define_libfunc("set-handler!", 3, 3, function (c, a) {
        throw new Error("set-handler! is obsolete, please use add-handler! instead")
    });
    define_libfunc("add-handler!", 3, 3, function (e, d) {
        var f = e[0],
            g = e[1],
            a = e[2];
        var c = d.on_error;
        Event.observe(f, g, function (j) {
            var h = new Interpreter(c);
            h.invoke_closure(a, [j || Window.event])
        });
        return BiwaScheme.undef
    });
    define_libfunc("wait-for", 2, 2, function (a) {
        var c = a[0],
            e = a[1];
        c.biwascheme_wait_for = c.biwascheme_wait_for || {};
        var d = c.biwascheme_wait_for[e];
        if (d) {
            Event.stopObserving(c, e, d)
        }
        return new BiwaScheme.Pause(function (g) {
            var f = function (h) {
                c.biwascheme_wait_for[e] = undefined;
                Event.stopObserving(c, e, f);
                return g.resume(BiwaScheme.undef)
            };
            c.biwascheme_wait_for[e] = f;
            Event.observe(c, e, f)
        })
    });
    define_libfunc("domelem", 1, null, function (a) {
        throw new Error("obsolete")
    });
    define_libfunc("dom-remove-children!", 1, 1, function (a) {
        puts("warning: dom-remove-children! is obsolete. use element-empty! instead");
        $(a[0]).update("");
        return BiwaScheme.undef
    });
    define_libfunc("dom-create-element", 1, 1, function (a) {
        throw new Error("obsolete")
    });
    define_libfunc("element-append-child!", 2, 2, function (a) {
        return $(a[0]).appendChild(a[1])
    });
    define_libfunc("dom-remove-child!", 2, 2, function (a) {
        throw new Error("obsolete")
    });
    define_libfunc_raw("js-eval", 1, 1, function (ar) {
        return eval(ar[0])
    });
    define_libfunc_raw("js-ref", 2, 2, function (a) {
        assert_string(a[1]);
        return a[0][a[1]]
    });
    define_libfunc("js-set!", 3, 3, function (a) {
        assert_string(a[1]);
        a[0][a[1]] = a[2];
        return BiwaScheme.undef
    });
    define_libfunc_raw("js-call", 1, null, function (a) {
        var c = a.shift();
        assert_function(c);
        var d = null;
        return c.apply(d, a)
    });
    define_libfunc_raw("js-invoke", 2, null, function (d) {
        var c = d.shift();
        var a = d.shift();
        assert_string(a);
        if (c[a]) {
            return c[a].apply(c, d)
        } else {
            throw new Error("js-invoke: function " + a + " is not defined")
        }
    });
    define_libfunc("js-new", 1, null, function (ar, intp) {
        var array_to_obj = function (ary) {
            if ((ary.length % 2) != 0) {
                throw new Error("js-new: odd number of key-value pair")
            }
            var obj = {};
            for (var i = 0; i < ary.length; i += 2) {
                var key = ary[i],
                    value = ary[i + 1];
                assert_symbol(key);
                if (value.closure_p === true) {
                    value = BiwaScheme.js_closure(value, intp)
                }
                obj[key.name] = value
            }
            return obj
        };
        var ctor = ar.shift();
        assert_string(ctor);
        if (ar.length == 0) {
            return eval("new " + ctor + "()")
        } else {
            var args = [];
            for (var i = 0; i < ar.length; i++) {
                if (ar[i] instanceof Symbol) {
                    args.push(array_to_obj(ar.slice(i)));
                    break
                } else {
                    args.push(ar[i])
                }
            }
            var args_str = ar.map(function (value, i) {
                return "args['" + i + "']"
            }).join(",");
            return eval("new " + ctor + "(" + args_str + ")")
        }
    });
    define_libfunc("js-obj", 0, null, function (a) {
        if (a.length % 2 != 0) {
            throw new Error("js-obj: number of arguments must be even")
        }
        var c = {};
        for (i = 0; i < a.length / 2; i++) {
            assert_string(a[i * 2]);
            c[a[i * 2]] = a[i * 2 + 1]
        }
        return c
    });
    BiwaScheme.js_closure = function (a, d) {
        var c = d.on_error;
        return function () {
            var e = new Interpreter(c);
            e.invoke_closure(a, $A(arguments))
        }
    };
    define_libfunc("js-closure", 1, 1, function (c, a) {
        assert_closure(c[0]);
        return BiwaScheme.js_closure(c[0], a)
    });
    define_libfunc("js-null?", 1, 1, function (a) {
        return a[0] === null
    });
    define_libfunc("js-undefined?", 1, 1, function (a) {
        return a[0] === undefined
    });
    define_libfunc("http-request", 1, 1, function (a) {
        var c = a[0];
        assert_string(c);
        return new BiwaScheme.Pause(function (d) {
            new Ajax.Request(c, {
                method: "get",
                onSuccess: function (e) {
                    d.resume(e.responseText)
                }
            })
        })
    });
    define_libfunc("http-post", 2, 2, function (a) {
        var e = a[0];
        assert_string(e);
        var d = a[1];
        assert_list(d);
        var c = {};
        d.foreach(function (f) {
            assert_string(f.car);
            c[f.car] = f.cdr
        });
        return new BiwaScheme.Pause(function (f) {
            new Ajax.Request(e, {
                method: "post",
                postBody: $H(c).toQueryString(),
                onSuccess: function (g) {
                    f.resume(g.responseText)
                }
            })
        })
    });
    BiwaScheme.jsonp_receiver = [];
    define_libfunc("receive-jsonp", 1, 1, function (a) {
        var d = a[0];
        assert_string(d);
        var f = BiwaScheme.jsonp_receiver;
        for (var e = 0; e < f.length; e++) {
            if (f[e] === null) {
                break
            }
        }
        var c = e;
        d += "?callback=BiwaScheme.jsonp_receiver[" + c + "]";
        return new BiwaScheme.Pause(function (h) {
            f[c] = function (j) {
                h.resume(j);
                f[c] = null
            };
            var g = document.createElement("script");
            g.src = d;
            document.body.appendChild(g)
        })
    });
    define_libfunc("alert", 1, 1, function (a) {
        alert(a[0]);
        return BiwaScheme.undef
    });
    define_libfunc("confirm", 1, 1, function (a) {
        return confirm(a[0])
    });
    BiwaScheme.TupleSpaceClient = Class.create({
        initialize: function (a) {
            this.server_path = a
        },
        nonblocking_request: function (a, c) {
            var d = this.server_path + a + "?" + encodeURIComponent(to_write(c));
            return this.connect(d)
        },
        blocking_request: function (a, c) {
            this.assert_init();
            var d = this.server_path + a + "?" + encodeURIComponent(to_write(c)) + "&cid=" + this.client_id;
            return new BiwaScheme.Pause(function (e) {
                this.ajax(d, function (f) {
                    this.observe(f, function (g) {
                        e.resume(g)
                    })
                }.bind(this))
            }.bind(this))
        },
        write: function (a) {
            return this.nonblocking_request("write", a)
        },
        readp: function (a) {
            return this.nonblocking_request("readp", a)
        },
        takep: function (a) {
            return this.nonblocking_request("takep", a)
        },
        dump: function () {
            return this.nonblocking_request("dump", "")
        },
        read: function (a) {
            return this.blocking_request("read", a)
        },
        take: function (a) {
            return this.blocking_request("take", a)
        },
        ajax: function (a, c) {
            new Ajax.Request(a, {
                onSuccess: function (d) {
                    c(d.responseText)
                },
                onFailure: function () {
                    puts("error: failed to access " + a)
                }
            })
        },
        init_connection: function () {
            if (this.client_id) {
                return this.client_id
            } else {
                return new Pause(function (c) {
                    var a = this.server_path + "init_connection";
                    this.ajax(a, function (d) {
                        this.client_id = d;
                        this.start_connection();
                        c.resume(this.client_id)
                    }.bind(this))
                }.bind(this))
            }
        },
        assert_init: function () {
            if (!this.client_id) {
                puts("ts-init not called:" + Object.inspect(this.client_id));
                throw new Error("ts-init not called")
            }
        },
        start_connection: function () {
            var c = this.server_path + "connection?cid=" + this.client_id;
            var a = function () {
                this.ajax(c, function (g) {
                    var e = Interpreter.read(g);
                    var f = e.car,
                        d = e.cdr;
                    this.notify(f, d);
                    a()
                }.bind(this))
            }.bind(this);
            a()
        },
        waiters: [],
        too_early_tuples: [],
        observe: function (a, c) {
            if (this.too_early_tuples[a]) {
                c(this.too_early_tuples[a]);
                this.too_early_tuples[a] = undefined
            } else {
                if (this.waiters[a]) {
                    puts("Bug: ticket conflicted")
                } else {
                    this.waiters[a] = c
                }
            }
        },
        notify: function (c, a) {
            var d = this.waiters[c];
            if (d) {
                this.waiters[c] = undefined;
                return d(a)
            } else {
                this.too_early_tuples[c] = a
            }
        },
        connect: function (c, a) {
            c += "&time=" + (new Date()).getTime();
            return new BiwaScheme.Pause(function (d) {
                new Ajax.Request(c, {
                    method: "get",
                    onSuccess: function (f) {
                        var e = f.responseText;
                        if (a) {
                            e = a(e)
                        } else {
                            e = Interpreter.read(e)
                        }
                        if (e == undefined) {
                            d.resume(false)
                        } else {
                            d.resume(e)
                        }
                    },
                    onFailure: function (e) {
                        throw new Error("ts_client.connect: failed to access" + c);
                        d.resume(false)
                    }
                })
            })
        }
    });
    BiwaScheme.ts_client = new TupleSpaceClient("/ts/");
    define_libfunc("ts-init", 0, 0, function (a) {
        return ts_client.init_connection()
    });
    define_libfunc("ts-write", 1, 1, function (a) {
        return ts_client.write(a[0])
    });
    define_libfunc("ts-read", 1, 1, function (a) {
        var c = a[0];
        return ts_client.read(c)
    });
    define_libfunc("ts-readp", 1, 1, function (a) {
        return ts_client.readp(a[0])
    });
    define_libfunc("ts-take", 1, 1, function (a) {
        return ts_client.take(a[0])
    });
    define_libfunc("ts-takep", 1, 1, function (a) {
        return ts_client.takep(a[0])
    });
    define_libfunc("ts-dump", 0, 0, function (a) {
        return ts_client.dump()
    })
}
if (typeof(BiwaScheme) != "object") {
    BiwaScheme = {}
}
with(BiwaScheme) {
    define_libfunc("html-escape", 1, 1, function (a) {
        assert_string(a[0]);
        return a[0].escapeHTML()
    });
    BiwaScheme.inspect_objs = function (a) {
        return a.map(function (c) {
            if (c.inspect) {
                return c.inspect()
            } else {
                return Object.inspect($H(c))
            }
        }).join(", ")
    };
    define_libfunc("inspect", 1, null, function (a) {
        return BiwaScheme.inspect_objs(a)
    });
    define_libfunc("inspect!", 1, null, function (a) {
        puts(BiwaScheme.inspect_objs(a));
        return BiwaScheme.undef
    });
    BiwaScheme.json2sexp = function (c) {
        switch (true) {
        case Object.isNumber(c) || Object.isString(c) || c === true || c === false:
            return c;
        case Object.isArray(c):
            return c.map(function (d) {
                return json2sexp(d)
            }).to_list();
        case typeof(c) == "object":
            var a = nil;
            for (key in c) {
                a = new Pair(new Pair(key, json2sexp(c[key])), a)
            }
            return a;
        default:
            throw new Error("json->sexp: detected invalid value for json: " + Object.inspect(c))
        }
        throw new Bug("must not happen")
    };
    define_libfunc("json->sexp", 1, 1, function (a) {
        return json2sexp(a[0])
    });
    define_libfunc("identity", 1, 1, function (a) {
        return a[0]
    });
    define_libfunc("string-concat", 1, 1, function (a) {
        assert_list(a[0]);
        return a[0].to_array().join("")
    });
    define_libfunc("string-split", 2, 2, function (a) {
        assert_string(a[0]);
        assert_string(a[1]);
        return a[0].split(a[1]).to_list()
    });
    define_libfunc("string-join", 1, 2, function (a) {
        assert_list(a[0]);
        var c = "";
        if (a[1]) {
            assert_string(a[1]);
            c = a[1]
        }
        return a[0].to_array().join(c)
    });
    define_libfunc("intersperse", 2, 2, function (c) {
        var e = c[0],
            a = c[1];
        assert_list(a);
        var d = [];
        a.to_array().reverse().each(function (f) {
            d.push(f);
            d.push(e)
        });
        d.pop();
        return d.to_list()
    });
    define_libfunc("map-with-index", 2, null, function (d) {
        var c = d.shift(),
            a = d;
        a.each(function (g) {
            assert_list(g)
        });
        var f = [],
            e = 0;
        return Call.multi_foreach(a, {
            call: function (h) {
                var g = h.map(function (j) {
                    return j.car
                });
                g.unshift(e);
                e++;
                return new Call(c, g)
            },
            result: function (g) {
                f.push(g)
            },
            finish: function () {
                return f.to_list()
            }
        })
    });
    var rearrange_args = function (d, f) {
        var a = [];
        var e = (new Compiler).find_dot_pos(d);
        if (e == -1) {
            a = f
        } else {
            for (var c = 0; c < e; c++) {
                a[c] = f[c]
            }
            a[c] = f.slice(c).to_list()
        }
        return a
    };
    define_syntax("define-macro", function (c) {
        var h = c.cdr.car;
        var e;
        if (h instanceof Pair) {
            var g = h.car;
            e = h.cdr;
            var a = c.cdr.cdr;
            var f = new Pair(Sym("lambda"), new Pair(e, a))
        } else {
            var g = h;
            var f = c.cdr.cdr.car;
            e = f.cdr.car
        }
        var j = Compiler.compile(f);
        if (j[1] != 0) {
            throw new Bug("you cannot use free variables in macro expander (or define-macro must be on toplevel)")
        }
        var d = [j[2]];
        TopEnv[g.name] = new Syntax(g.name, function (q) {
            var o = q.to_array();
            o.shift();
            var l = new Interpreter();
            var m = rearrange_args(e, o);
            var k = l.invoke_closure(d, m);
            return k
        });
        return BiwaScheme.undef
    });
    var macroexpand_1 = function (c) {
        if (c instanceof Pair) {
            if (c.car instanceof Symbol && TopEnv[c.car.name] instanceof Syntax) {
                var a = TopEnv[c.car.name];
                c = a.transform(c)
            } else {
                throw new Error("macroexpand-1: `" + to_write_ss(c) + "' is not a macro")
            }
        }
        return c
    };
    define_syntax("%macroexpand", function (a) {
        var c = (new Interpreter).expand(a.cdr.car);
        return [Sym("quote"), c].to_list()
    });
    define_syntax("%macroexpand-1", function (a) {
        var c = macroexpand_1(a.cdr.car);
        return [Sym("quote"), c].to_list()
    });
    define_libfunc("macroexpand", 1, 1, function (a) {
        return (new Interpreter).expand(a[0])
    });
    define_libfunc("macroexpand-1", 1, 1, function (a) {
        return macroexpand_1(a[0])
    });
    define_libfunc("gensym", 0, 0, function (a) {
        return BiwaScheme.gensym()
    });
    define_libfunc("print", 1, null, function (a) {
        a.map(function (c) {
            puts(to_display(c), true)
        });
        puts("");
        return BiwaScheme.undef
    });
    define_libfunc("write-to-string", 1, 1, function (a) {
        return to_write(a[0])
    });
    define_libfunc("read-from-string", 1, 1, function (a) {
        assert_string(a[0]);
        return Interpreter.read(a[0])
    });
    define_libfunc("port-closed?", 1, 1, function (a) {
        assert_port(a[0]);
        return !(a[0].is_open)
    });
    define_syntax("let1", function (c) {
        var d = c.cdr.car;
        var e = c.cdr.cdr.car;
        var a = c.cdr.cdr.cdr;
        return new Pair(new Pair(Sym("lambda"), new Pair(new Pair(d, nil), a)), new Pair(e, nil))
    });
    var assert_regexp = function (a, c) {
        if (!(a instanceof RegExp)) {
            throw new Error(c + ": regexp required, but got " + to_write(a))
        }
    };
    define_libfunc("string->regexp", 1, 1, function (a) {
        assert_string(a[0], "string->regexp");
        return new RegExp(a[0])
    });
    define_libfunc("regexp?", 1, 1, function (a) {
        return (a[0] instanceof RegExp)
    });
    define_libfunc("regexp->string", 1, 1, function (a) {
        assert_regexp(a[0], "regexp->string");
        return a[0].toString().slice(1, -1)
    });
    define_libfunc("regexp-exec", 2, 2, function (a) {
        var d = a[0];
        if (Object.isString(a[0])) {
            d = new RegExp(a[0])
        }
        assert_regexp(d, "regexp-exec");
        assert_string(a[1], "regexp-exec");
        var c = d.exec(a[1]);
        return (c === null) ? false : c.to_list()
    })
}
with(BiwaScheme) {
    define_libfunc("iota", 1, 3, function (d) {
        var g = d[0];
        var j = d[1] || 0;
        var f = (d[2] === undefined) ? 1 : d[2];assert_integer(g);assert_number(j);assert_number(f);
        var c = [],
            h = j;
        for (var e = 0; e < g; e++) {
            c.push(h);
            h += f
        }
        return c.to_list()
    });
    define_libfunc("open-input-string", 1, 1, function (a) {
        assert_string(a[0]);
        return new Port.StringInput(a[0])
    });
    define_libfunc("open-output-string", 0, 0, function (a) {
        return new Port.StringOutput()
    });
    define_libfunc("get-output-string", 1, 1, function (a) {
        assert_port(a[0]);
        if (!(a[0] instanceof Port.StringOutput)) {
            throw new Error("get-output-string: port must be made by 'open-output-string'")
        }
        return a[0].output_string()
    });
    define_libfunc("current-date", 0, 1, function (a) {
        return new Date()
    });
    define_libfunc("date?", 1, 1, function (a) {
        return (a[0] instanceof Date)
    });
    define_libfunc("date-nanosecond", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getMilliseconds() * 1000000
    });
    define_libfunc("date-millisecond", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getMilliseconds()
    });
    define_libfunc("date-second", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getSeconds()
    });
    define_libfunc("date-minute", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getMinutes()
    });
    define_libfunc("date-hour", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getHours()
    });
    define_libfunc("date-day", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getDate()
    });
    define_libfunc("date-month", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getMonth() + 1
    });
    define_libfunc("date-year", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getFullYear()
    });
    define_libfunc("date-week-day", 1, 1, function (a) {
        assert_date(a[0]);
        return a[0].getDay()
    });
    BiwaScheme.date_names = {
        weekday: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        full_weekday: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
        month: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
        full_month: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "Octorber", "November", "December"]
    };
    BiwaScheme.date2string = function (d, e) {
        var f = function (g) {
            return g < 10 ? "0" + g : "" + g
        };
        var c = function (g) {
            return g < 10 ? " " + g : "" + g
        };
        var a = {
            a: function (g) {
                return date_names.weekday[g.getDay()]
            },
            A: function (g) {
                return date_names.full_weekday[g.getDay()]
            },
            b: function (g) {
                return date_names.month[g.getMonth()]
            },
            B: function (g) {
                return date_names.full_month[g.getMonth()]
            },
            c: function (g) {
                return g.toString()
            },
            d: function (g) {
                return f(g.getDate())
            },
            D: function (g) {
                return a.d(g) + a.m(g) + a.y(g)
            },
            e: function (g) {
                return c(g.getDate())
            },
            f: function (g) {
                return g.getSeconds() + g.getMilliseconds() / 1000
            },
            h: function (g) {
                return date_names.month[g.getMonth()]
            },
            H: function (g) {
                return f(g.getHours())
            },
            I: function (g) {
                var j = g.getHours();
                return f(j < 13 ? j : j - 12)
            },
            j: function (g) {
                throw new Bug("not implemented: day of year")
            },
            k: function (g) {
                return c(g.getHours())
            },
            l: function (g) {
                var j = g.getHours();
                return c(j < 13 ? j : j - 12)
            },
            m: function (g) {
                return f(g.getMonth())
            },
            M: function (g) {
                return f(g.getMinutes())
            },
            n: function (g) {
                return "\n"
            },
            N: function (g) {
                throw new Bug("not implemented: nanoseconds")
            },
            p: function (g) {
                return g.getHours() < 13 ? "AM" : "PM"
            },
            r: function (g) {
                return a.I(g) + ":" + a.M(g) + ":" + a.S(g) + " " + a.p(g)
            },
            s: function (g) {
                return Math.floor(g.getTime() / 1000)
            },
            S: function (g) {
                return f(g.getSeconds())
            },
            t: function (g) {
                return "\t"
            },
            T: function (g) {
                return a.H(g) + ":" + a.M(g) + ":" + a.S(g)
            },
            U: function (g) {
                throw new Bug("not implemented: weeknum(0~, Sun)")
            },
            V: function (g) {
                throw new Bug("not implemented: weeknum(1~, Sun?)")
            },
            w: function (g) {
                return g.getDay()
            },
            W: function (g) {
                throw new Bug("not implemented: weeknum(0~, Mon)")
            },
            x: function (g) {
                throw new Bug("not implemented: weeknum(1~, Mon)")
            },
            X: function (g) {
                return a.Y(g) + "/" + a.m(g) + "/" + a.d(g)
            },
            y: function (g) {
                return g.getFullYear() % 100
            },
            Y: function (g) {
                return g.getFullYear()
            },
            z: function (g) {
                throw new Bug("not implemented: time-zone")
            },
            Z: function (g) {
                throw new Bug("not implemented: symbol time zone")
            },
            1: function (g) {
                throw new Bug("not implemented: ISO-8601 year-month-day format")
            },
            2: function (g) {
                throw new Bug("not implemented: ISO-8601 hour-minute-second-timezone format")
            },
            3: function (g) {
                throw new Bug("not implemented: ISO-8601 hour-minute-second format")
            },
            4: function (g) {
                throw new Bug("not implemented: ISO-8601 year-month-day-hour-minute-second-timezone format")
            },
            5: function (g) {
                throw new Bug("not implemented: ISO-8601 year-month-day-hour-minute-second format")
            }
        };
        return e.replace(/~([\w1-5~])/g, function (h, g) {
            var j = a[g];
            if (j) {
                return j(d)
            } else {
                if (g == "~") {
                    return "~"
                } else {
                    return g
                }
            }
        })
    };
    define_libfunc("date->string", 1, 2, function (a) {
        assert_date(a[0]);
        if (a[1]) {
            assert_string(a[1]);
            return date2string(a[0], a[1])
        } else {
            return a[0].toString()
        }
    });
    define_libfunc("parse-date", 1, 1, function (a) {
        assert_string(a[0]);
        return new Date(Date.parse(a[0]))
    });
    define_libfunc("random-integer", 1, 1, function (a) {
        var c = a[0];
        assert_integer(c);
        if (c < 0) {
            throw new Error("random-integer: the argument must be >= 0")
        } else {
            return Math.floor(Math.random() * a[0])
        }
    });
    define_libfunc("random-real", 0, 0, function (a) {
        return Math.random()
    });
    var user_write_ss = function (a) {
        puts(write_ss(a[0]), true);
        return BiwaScheme.undef
    };
    define_libfunc("write/ss", 1, 2, user_write_ss);
    define_libfunc("write-with-shared-structure", 1, 2, user_write_ss);
    define_libfunc("write*", 1, 2, user_write_ss);
    define_libfunc("vector-append", 2, null, function (a) {
        var c = [];
        return c.concat.apply(c, a)
    })
}
with(BiwaScheme) {
    BiwaScheme.Dumper = Class.create({
        initialize: function (a) {
            this.dumparea = a || $("dumparea") || null;
            this.reset()
        },
        reset: function () {
            if (this.dumparea) {
                $(this.dumparea).update("")
            }
            this.n_folds = 0;
            this.closures = [];
            this.n_dumps = 0;
            this.cur = -1;
            this.is_folded = true
        },
        is_opc: function (a) {
            return (a instanceof Array && typeof(a[0]) == "string")
        },
        dump_pad: "&nbsp;&nbsp;&nbsp;",
        dump_opc: function (e, g) {
            var c = "";
            var f = "",
                d = "";
            var g = g || 0;
            g.times(function () {
                f += this.dump_pad
            }.bind(this));
            (g + 1).times(function () {
                d += this.dump_pad
            }.bind(this));
            c += f + '[<span class="dump_opecode">' + e[0] + "</span>";
            var a = 1;
            while (!(e[a] instanceof Array) && a < e.length) {
                if (e[0] == "constant") {
                    c += "&nbsp;<span class='dump_constant'>" + this.dump_obj(e[a]) + "</span>"
                } else {
                    c += "&nbsp;" + this.dump_obj(e[a])
                }
                a++
            }
            if (a < e.length) {
                c += "<br>\n"
            }
            for (; a < e.length; a++) {
                if (this.is_opc(e[a])) {
                    c += this.dump_opc(e[a], (a == e.length - 1 ? g : g + 1))
                } else {
                    c += (a == e.length - 1) ? f : d;c += this.dump_obj(e[a])
                }
                if (a != e.length - 1) {
                    c += "<br>\n"
                }
            }
            c += "]";
            return (g == 0 ? this.add_fold(c) : c)
        },
        fold_limit: 20,
        add_fold: function (f) {
            var c = f.split(/<br>/gmi);
            if (c.length > this.fold_limit) {
                var e = " <span style='text-decoration:underline; color:blue; cursor:pointer;'onclick='BiwaScheme.Dumper.toggle_fold(" + this.n_folds + ")'>more</span>";
                var a = "<div style='display:none' id='fold" + this.n_folds + "'>";
                var d = "</div>";
                this.n_folds++;
                return [c.slice(0, this.fold_limit).join("<br>"), e, a, c.slice(this.fold_limit + 1).join("<br>"), d].join("")
            } else {
                return f
            }
        },
        stack_max_len: 80,
        dump_stack: function (f, d) {
            if (f === null || f === undefined) {
                return Object.inspect(f)
            }
            var e = "<table>";
            if (f.length == 0) {
                e += "<tr><td class='dump_dead'>(stack is empty)</td></tr>"
            } else {
                if (d < f.length) {
                    var a = f.length - 1;
                    e += "<tr><td class='dump_dead'>[" + a + "]</td><td class='dump_dead'>" + this.dump_obj(f[a]).truncate(this.stack_max_len) + "</td></tr>"
                }
            }
            for (var c = d - 1; c >= 0; c--) {
                e += "<tr><td class='dump_stknum'>[" + c + "]</td><td>" + this.dump_obj(f[c]).truncate(this.stack_max_len) + "</td></tr>"
            }
            return e + "</table>"
        },
        dump_object: function (e) {
            var c = [];
            for (var d in e) {
                c.push(d.toString())
            }
            return "#<Object{" + c.join(",") + "}>"
        },
        dump_closure: function (d) {
            if (d.length == 0) {
                return "[]"
            }
            var g = null;
            for (var e = 0; e < this.closures.length; e++) {
                if (this.closures[e] == d) {
                    g = e
                }
            }
            if (g == null) {
                g = this.closures.length;
                this.closures.push(d)
            }
            var f = d.clone ? d.clone() : [f];
            var a = f.shift();
            return ["c", g, " <span class='dump_closure'>free vars :</span> ", this.dump_obj(f), " <span class='dump_closure'>body :</span> ", this.dump_obj(a).truncate(100)].join("")
        },
        dump_obj: function (c) {
            if (c && typeof(c.to_html) == "function") {
                return c.to_html()
            } else {
                var a = write_ss(c, true);
                if (a == "[object Object]") {
                    a = this.dump_object(c)
                }
                return a.escapeHTML()
            }
        },
        dump: function (d) {
            var c = document.createElement("div");
            var a = "";
            if (d instanceof Hash) {
                a += "<table>";
                a += "<tr><td colspan='4'><a href='#' id='dump_" + this.n_dumps + "_header'>#" + this.n_dumps + "</a></td></tr>";
                d.each(function (f) {
                    if (f.key != "x" && f.key != "stack") {
                        var e = (f.key == "c" ? this.dump_closure(f.value) : this.dump_obj(f.value));
                        a += "<tr><td>" + f.key + ": </td><td colspan='3'>" + e + "</td></tr>"
                    }
                }.bind(this));
                a += "<tr><td>x:</td><td>" + (this.is_opc(d.get("x")) ? this.dump_opc(d.get("x")) : this.dump_obj(d.get("x"))) + "</td>";
                a += "<td style='border-left: 1px solid black'>stack:</td><td>" + this.dump_stack(d.get("stack"), d.get("s")) + "</td></tr>";
                a += "</table>"
            } else {
                a = Object.inspect(d).escapeHTML() + "<br>\n"
            }
            c.id = "dump" + this.n_dumps;
            c.innerHTML = a;
            this.dumparea.appendChild(c);
            (function (e) {
                $("dump_" + this.n_dumps + "_header").observe("click", function () {
                    this.dump_move_to(e);
                    this.dump_fold()
                }.bind(this))
            }.bind(this))(this.n_dumps);
            Element.hide(c);
            this.n_dumps++
        },
        dump_move_to: function (a) {
            if (0 <= a && a <= this.n_dumps) {
                Element.hide($("dump" + this.cur));
                this.cur = a;
                Element.show($("dump" + this.cur))
            }
        },
        dump_move: function (a) {
            if (0 <= this.cur && this.cur < this.n_dumps) {
                Element.hide($("dump" + this.cur))
            }
            if (0 <= this.cur + a && this.cur + a < this.n_dumps) {
                this.cur += a
            }
            Element.show($("dump" + this.cur))
        },
        dump_fold: function () {
            for (var a = 0; a < this.n_dumps; a++) {
                if (a != this.cur) {
                    Element.hide($("dump" + a))
                }
            }
            this.is_folded = true
        },
        dump_unfold: function () {
            for (var a = 0; a < this.n_dumps; a++) {
                Element.show($("dump" + a))
            }
            this.is_folded = false
        },
        dump_toggle_fold: function () {
            if (this.is_folded) {
                this.dump_unfold()
            } else {
                this.dump_fold()
            }
        }
    })
}
BiwaScheme.Dumper.toggle_fold = function (a) {
    Element.toggle("fold" + a)
};
(function () {
    var h = function (k, e) {
        if ( !! (window.attachEvent && !window.opera)) {
            var j = {
                names: {
                    "class": "className",
                    "for": "htmlFor"
                },
                values: {
                    _getAttr: function (l, m) {
                        return l.getAttribute(m, 2)
                    },
                    _getAttrNode: function (l, o) {
                        var m = l.getAttributeNode(o);
                        return m ? m.value : ""
                    },
                    _getEv: function (l, m) {
                        var m = l.getAttribute(m);
                        return m ? m.toString().slice(23, -2) : null
                    },
                    _flag: function (l, m) {
                        return $(l).hasAttribute(m) ? m : null
                    },
                    style: function (l) {
                        return l.style.cssText.toLowerCase()
                    },
                    title: function (l) {
                        return l.title
                    }
                }
            };
            if (j.values[e]) {
                return j.values[e](k, e)
            }
            if (j.names[e]) {
                e = j.names[e]
            }
            if (e.indexOf(":") > -1) {
                return (!k.attributes || !k.attributes[e]) ? null : k.attributes[e].value
            }
        }
        return k.getAttribute(e)
    };
    var d = function (j) {
        if (j.nodeName.toLowerCase() == "script") {
            return j
        } else {
            if (j.id == "_firebugConsole") {
                if (j.previousSibling.nodeName.toLowerCase() == "script") {
                    return j.previousSibling
                } else {
                    console.error("BiwaScheme could not find the script tag... please use firebug 1.5.0")
                }
            } else {
                return d(j.lastChild)
            }
        }
    };
    var c = d(document);
    var f = function (l, k) {
        puts(l.message);
        if ($("biwascheme-debugger")) {
            var j = new BiwaScheme.Dumper($("biwascheme-debugger"));
            j.dump(new Hash(k));
            j.dump_move(1)
        }
        throw (l)
    };
    var a = new BiwaScheme.Interpreter(f);
    try {
        a.evaluate(c.innerHTML, Prototype.emptyFunction)
    } catch (g) {
        f(g)
    }
})();