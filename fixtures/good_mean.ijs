NB. clean sample — should lint and load cleanly
mean =: +/ % #
sumsq =: +/ @: *:

demo =: 3 : 0
  m=. mean y
  s=. sumsq y
  m ; s
)
