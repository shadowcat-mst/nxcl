$ 1 + 2
= 3
$ 1 + 2; 3 + 4
= 7
$ 1 - 3
= -2
$ 1.minus 3
= -2
$ 1.eq 3
= false
$ 1.eq 1
= true
$ 1 == 1
= true
$ 1 == 3
= false
$ 1.eq(1)
= true
$ 1.plus(2, 3)
= 6
$ 1.plus 2 3
= 6
$ 'foo' ++ 'bar'
= 'foobar'
$ (3, 2, 1)(1)
= 2
$ .plus() 1 2 3
= 6
$ .plus(1) 2 3
= 6
$ (1, 2, 3).map .plus(1)
= (2, 3, 4)
$ + 1 2 3
= 6
$ (1, 2, 3) ++ (4, 5)
= (1, 2, 3, 4, 5)
$ ( (1), (2), (3) ).map .concat(('x'))
= (('x', 1), ('x', 2), ('x', 3))
$ [ 1 == 1 ].ifelse 3 4
= 3
$ [ 1 == 0 ].ifelse 3 [3+4]
= 7
$ 3 + 2 * 4
= 11
$ let x = 3; x + 2
= 5
$ let x = [ let y = 3 ] + 4;
= 7
$ let (x, y) = (1, 2); y + 3;
= 5
$ var x = 3;
  do { let y = 4; x = x + y }
  x
= 7
$ let f = fun (x) { x + 1 }; f 3
= 4
$ let f = do { let x = 3; fun (y) { x + y } }; f 7
= 10
$ let f = fun (x) { x.ifelse do{ return 1 } 2; 3 }; f false
= 3
$ let x = 4; let y = x; y
= 4
$ let f = fun (x) { x.ifelse do{ return 1 } 2; 3 }; f true
= 1
$ var x = 1;
  let inc = fun () { x = x + 1 }
  inc();
  inc();
  x
= 3
$ var x = 1;
  let inc = fun () { x = x + 1 } # increment
  inc();
  inc();
  x
= 3
$ let nf = fexpr (cx, name) { name }
  nf foo
= foo
$ var x = 1;
  let run-twice = fexpr (cx, expr) {
    cx.eval expr;
    cx.eval expr;
  }
  run-twice [ x = x + 1 ];
  x
= 3
$ let expr-then-0 = fexpr (cx, expr) {
    cx.eval expr;
    0;
  }
  let f1 = fun () {
    expr-then-0 17;
  }
  let f2 = fun () {
    expr-then-0 17;
    1;
  }
  let f3 = fun () {
    expr-then-0 return(2);
    1;
  }
  (f1(), f2(), f3())
= (0, 1, 2)
$ let run-both = fexpr (cx, e1, e2) {
    cx.eval e1;
    cx.eval e2;
  }
  let x = 1;
  var y = 3;
  run-both [ let x = 7 ] [ y = y + x ];
  (x, y)
= (7, 10)
$ let run-both = fexpr (cx, e1, e2) {
    let cx = cx.derive();
    cx.eval e1;
    cx.eval e2;
  }
  let x = 1;
  var y = 3;
  run-both [ let x = 7 ] [ y = y + x ];
  (x, y)
= (1, 10)
$ let _if = fexpr (cx, cond, onif, onelse) {
    let cx = cx.derive();
    let res = cx.eval cond;
    cx.call [res.ifelse onif onelse]
  }
  let lt3 = fun (val) {
    _if [ val > 2 ] {
      return 'boo'
    } {
      return '<3'
    }
    'notreached'
  }
  let lt3-retv = fun (val) {
    let v = 0;
    let r = _if [ [ let v = val ] > 2 ] {
      v
    } {
      '<3'
    }
    (v, r)
  }
  (lt3 2, lt3 7, lt3-retv 2, lt3-retv 7)
= ('<3', 'boo', (0, '<3'), (0, 7))
$ let -?:- = fexpr (cx, cond, onif, onelse) {
    let cx = cx.derive();
    let res = cx.eval cond;
    cx.eval [res.ifelse onif onelse]
  }
  let lt3 = fun (val) { -?:- [ val > 2 ] 'boo' '<3' }
  (lt3 2, lt3 7)
= ('<3', 'boo')
$ let _defer = fexpr (cx, cb) {
    cx.defer cb
  }
  var x = 1;
  var y = 2;
  var savx = 0;
  var savy = 0;
  let f = fun () {
    _defer { x = 3 }
    _defer { y = 5 + x }
    savx = x;
    savy = y;
    7
  }
  let z = f();
  (x, y, z, savx, savy);
= (3, 6, 7, 1, 2)
$ var x = 1;
  var y = 2;
  var savx = 0;
  var savy = 0;
  let f = fun () {
    defer { x = 3 }
    defer { y = 5 + x }
    savx = x;
    savy = y;
    7
  }
  let z = f();
  (x, y, z, savx, savy);
= (3, 6, 7, 1, 2)
$ let earlyret = fun () {
    ^return 3;
    0;
  }
  earlyret()
= 3
$ let dynrecv = fun () { ^dyn-name }
  let dynmid = fun () { dynrecv() }
  let dynsend = fun () {
    ^dyn-name = 3;
    dynmid()
  }
  dynsend()
= 3
$ let -^- = LvalueFun.new(
    fexpr (cx, name) { cx.get_dynamic_value name },
    fexpr (cx, targp, value) {
      let name = targp.first();
      cx.set_dynamic_value name value
    },
  );
  let dynrecv = fun () { -^-dyn-name }
  let dynmid = fun () { dynrecv() }
  let dynsend = fun () {
    -^-dyn-name = 3;
    dynmid()
  }
  dynsend()
= 3
$ \[ x(1); y    2 ]
= [ x(1); y 2 ]
$ { let y = 4; x = x + y }
= { = [ let y ] 4; = x [ + x y ] }
$ let foo = fexpr (cx) {
    cx.expr_stack()
  }
  let bar = fun () { foo() }
  bar()
= (foo(), { foo() }, fun () { foo() }, bar(), [ = [ let foo ] [ fexpr (cx) { [ . cx expr_stack ] } ]; = [ let bar ] [ fun () { foo() } ]; bar() ])
