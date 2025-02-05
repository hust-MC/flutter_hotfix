// 给GLOBAL Map传入key为'dynaPage'的值
// 值为一个立即执行函数
GLOBAL['dynaPage'] = (function() {
    const __global__ = this;
    return runCallback(function(__mod__) {
        with(__mod__.imports) {
            function _MyHomePageState() {
                const inner = _MyHomePageState.__inner__;
                if (this == __global__) {
                    return new _MyHomePageState({
                        __args__: arguments
                    });
                } else {
                    const args = arguments.length > 0 ? arguments[0].__args__ || arguments : [];
                    inner.apply(this, args);
                    _MyHomePageState.prototype.ctor.apply(this, args);
                    return this;
                }
            }
            _MyHomePageState.__inner__ = function inner() {
                this._counter = 0;
            };
            _MyHomePageState.prototype = {
                _incrementCounter: function _incrementCounter() {
                    const __thiz__ = this;
                    with(__thiz__) {
                        setState('dynaPage', function dummy() {
                            _counter++;
                        });
                    }
                },
            };
            _MyHomePageState.prototype.ctor = function() {
            };
            return _MyHomePageState();
        }
    }, []);
})();