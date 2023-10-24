# A Fruit Exercise

Let's use the logical modelling tool to choose some fruit.

The constraints:

1. At least one of `apples`, `oranges`, `pears`, or `bananas` must be chosen.
2. If `apples` is chosen, then we must choose `oranges`
3. If `bananas` is chosen, then we must not choose `pears`.
4. We cannot have both `oranges` and `pears`.

Fill in the definitions below to express these constraints in logical form:

```lmt {id=exercise}
atom apples
atom oranges
atom pears
atom bananas

define constraint1 {
  you_fill_this_in
}

define constraint2 {
  and_this
}

define constraint3 {
  and_this_one
}

define constraint4 {
  and_here
}

allsat (constraint1 & constraint2 & constraint3 & constraint4)
  { "apples" : apples, "oranges" : oranges, "pears" : pears, "bananas" : bananas }
```

The output should look like this, with 6 possible solutions:

```
{
  "apples": false,
  "oranges": true,
  "pears": false,
  "bananas": false
}
{
  "apples": false,
  "oranges": false,
  "pears": false,
  "bananas": true
}
{
  "apples": true,
  "oranges": true,
  "pears": false,
  "bananas": false
}
{
  "apples": false,
  "oranges": true,
  "pears": false,
  "bananas": true
}
{
  "apples": true,
  "oranges": true,
  "pears": false,
  "bananas": true
}
{
  "apples": false,
  "oranges": false,
  "pears": true,
  "bananas": false
}
```
