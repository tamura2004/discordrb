# ダイス
def r(code)
  n, m, k = code.split(/[dD\+]/).map(&:to_i)
  Array.new(n) { rand(1..m) }.sum + (k || 0)
end
