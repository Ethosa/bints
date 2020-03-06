# author: Ethosa

type
  Bint* = ref object
    number: seq[uint16]
    un: bool

proc bint*(numbers: varargs[uint16]): Bint
proc `$`*(a: Bint, separator: string = " "): string
proc `-`*(a, b: Bint): Bint
proc `+`*(a, b: Bint): Bint
proc `-`*(a: Bint): Bint
proc `*`*(a: Bint, b: int): Bint
proc `*`*(a, b: Bint): Bint
proc `^`*(a: Bint, b: int): Bint
proc `^`*(a, b: Bint): Bint
proc `div`*(a, b: Bint): Bint
proc `%`*(a, b: Bint): Bint
proc inc*(a: Bint): Bint {.inline.}
proc dec*(a: Bint): Bint {.inline.}
proc toInt*(a: Bint): int
proc `>`*(a, b: Bint): bool
proc `<`*(a, b: Bint): bool
proc `==`*(a, b: Bint): bool {.inline.}
proc `!=`*(a, b: Bint): bool {.inline.}
proc `>=`*(a, b: Bint): bool {.inline.}
proc `<=`*(a, b: Bint): bool {.inline.}
proc abs*(a: Bint): Bint {.inline.}

const
  MAX: uint16 = 999
  MAX1: uint16 = 1000
let BINT_FOR_INCDEC: Bint = bint(1)

proc abs(a: int): int {.inline.} =
  ## Always returns positive number.
  if a < 0: -a else: a

proc bint(numbers: varargs[uint16]): Bint =
  ## Converts numbers to the Big Integer object.
  ##
  ## Arguments:
  ## -   ``numbers`` -- list of numbers.
  ##
  ## ..code-block::Nim
  ##   var number = bint(7, 100, 200)
  ##   echo number # output is "7 100 200"
  result = Bint(number: @[], un: false)
  for n in countdown(numbers.len-1, 0, 1):
    if numbers[n] < MAX1:
      result.number.add(numbers[n])
    else:
      result.number.add(abs(MAX1.int - numbers[n].int).uint16)


iterator range*(start, finish, step: Bint = BINT_FOR_INCDEC): Bint =
  if step.un:
    var
      now = start
      s = step
    s.un = false
    while now > finish:
      now = now - s
      yield now
  else:
    var now = start
    while now < finish:
      now = now + step
      yield now


proc `$`(a: Bint, separator: string = " "): string =
  result = ""
  let length = a.number.len-1
  if a.un:
    result &= "-"
  for i in countdown(length, 0, 1):
    var to_add = $a.number[i]
    if i < length:
      # This adds 0 or 00 in start `to_add`, if available.
      if to_add.len == 1:
        result &= "00" & to_add
      elif to_add.len == 2:
        result &= "0" & to_add
      else:
        result &= to_add
    else:
      result &= to_add
    if i > 0:
      result &= separator

proc `+`(a, b: Bint): Bint =
  ## Sums up two numbers.
  ##
  ## Arguments:
  ## -   ``a`` -- first Big Integer.
  ## -   ``b`` -- second Big Integer.
  if not a.un:
    result = bint()
    var
      al = a.number.len
      bl = b.number.len
      lena = if al > bl: bl else: al
      lenb = if al > bl: al else: bl
    result.number = a.number
    for i in 0..<lenb:
      if i < lena:
        let sum = result.number[i] + b.number[i]
        if sum > MAX:
          result.number[i] = abs(MAX1.int - sum.int).uint16
          if i+1 < lenb:
            result.number[i+1] += sum div MAX1
          else:
            result.number.add(sum div MAX1)
        else:
          result.number[i] = sum
      else:
        if bl > al:
          result.number.add b.number[i]
        if result.number[i] > MAX:
          let sum = result.number[i]
          result.number[i] = abs(MAX1.int - sum.int).uint16
          if i+1 < lenb:
            result.number[i+1] += sum div MAX1
          else:
            result.number.add(sum div MAX1)
    if result.un and result >= bint(0):
      result.un = false
  else:
    a.un = false
    result = a - b
    result.un = not result.un

proc `-`(a, b: Bint): Bint =
  if not a.un:
    result = bint()
    var
      al = a.number.len
      bl = b.number.len
      lena = if al > bl: bl else: al
      lenb = if al > bl: al else: bl
    result.number = a.number
    if a < b:
      result.un = true
    for i in 0..<lenb:
      if i < lena:
        let sum = result.number[i].int - b.number[i].int
        if sum < 0 and i != lenb-1:
          result.number[i] = abs(MAX1.int + sum).uint16
          if abs(MAX1.int - sum).uint16 > MAX1 and i+1 < lenb:
            for j in i+1..<lenb:
              if result.number[j] == 0:
                result.number[j] = 999
              else:
                result.number[j] -= 1
        elif sum < 0:
          result.number[i] = abs(sum).uint16
        else:
          result.number[i] = abs(sum).uint16
      else:
        if bl > al:
          result.number.add b.number[i]
    while result.number[^1] == 0 and result.number.len > 1:
      discard result.number.pop()
    if result.un and result >= bint(0):
      result.un = false
  else:
    a.un = false
    result = a + b
    result.un = not result.un

proc `-`(a: Bint): Bint =
  result = a
  result.un = not result.un

proc `*`(a: Bint, b: int): Bint =
  result = a
  for _ in 1..<b:
    result = result + a

proc `*`(a, b: Bint): Bint =
  result = a
  for _ in range(bint(1), b):
    result = result + a

proc `^`(a: Bint, b: int): Bint =
  result = a
  for _ in 1..<b:
    result = result * a

proc `^`(a, b: Bint): Bint =
  result = a
  for _ in range(bint(1), b):
    result = result * a

proc `div`(a, b: Bint): Bint =
  var rem: Bint
  result = bint()
  for i in range(a, bint(0), -b):
    result = result + BINT_FOR_INCDEC
    rem = i

proc `%`(a, b: Bint): Bint =
  var quot: Bint = bint(0)
  result = bint()
  for i in range(a, bint(0), -b):
    quot = inc quot
    result = i
  result = abs(result)

proc inc(a: Bint): Bint {.inline.} =
  ## Increment
  return a + BINT_FOR_INCDEC

proc dec(a: Bint): Bint {.inline.} =
  ## Decrement
  return a - BINT_FOR_INCDEC

proc toInt(a: Bint): int =
  ## Converts Big Integer to Integer.
  result = a.number[0].int
  for i in 1..<a.number.len:
    var counter = 1000
    for _ in 1..i-1:
      counter *= 1000
    result += counter * a.number[i].int
  if a.un:
    result = -result


proc `>`(a, b: Bint): bool =
  if not a.un and b.un:
    return true
  elif not a.un and not b.un:
    if a.number.len > b.number.len:
      return true
    elif a.number.len == b.number.len:
      return a.number[^1] > b.number[^1]
  elif a.un and b.un:
    if a.number.len < b.number.len:
      return true
    elif a.number.len == b.number.len:
      return a.number[^1] < b.number[^1]
  return false

proc `<`(a, b: Bint): bool =
  if a.un and not b.un:
    return true
  elif not a.un and not b.un:
    if a.number.len < b.number.len:
      return true
    elif a.number.len == b.number.len:
      return a.number[^1] < b.number[^1]
  elif a.un and b.un:
    if a.number.len > b.number.len:
      return true
    elif a.number.len == b.number.len:
      return a.number[^1] > b.number[^1]
  return false

proc `==`(a, b: Bint): bool {.inline.} =
  return a.un == b.un and a.number == b.number

proc `!=`(a, b: Bint): bool {.inline.} =
  return a.un != b.un and a.number != b.number

proc `>=`(a, b: Bint): bool {.inline.} =
  a > b or a == b
proc `<=`(a, b: Bint): bool {.inline.} =
  a < b or a == b

proc abs(a: Bint): Bint {.inline.} =
  ## Always returns the positive Big Integer.
  if a.un: -a else: a


converter bool*(a: Bint): bool =
  return a.number.len == 0 and a.number[0] == 0

converter uint16*(a: Bint): uint16 =
  return a.number[0]
