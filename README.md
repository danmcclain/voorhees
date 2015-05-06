Voorhees
========

[![Build Status](https://travis-ci.org/danmcclain/voorhees.svg?branch=master)](https://travis-ci.org/danmcclain/voorhees)
[![Inline docs](http://inch-ci.org/github/danmcclain/voorhees.svg?branch=master)](http://inch-ci.org/github/danmcclain/voorhees)

A library for validating JSON responses

## Documentation

API documentation can be found at [http://hexdocs.pm/voorhees](http://hexdocs.pm/voorhees)

## Examples

### `Voorhees.matches_payload?`

Expected payload keys can be either strings or atoms

    iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
    true

Extra key/value pairs in payload are ignored

    iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz" })
    true

Extra key/value pairs in expected payload cause the validation to fail

    iex> payload = ~S[{ "foo": 1, "bar": "baz"}]
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => "baz", :boo => 3 })
    false

Validates scalar lists

    iex> payload = ~S/{ "foo": 1, "bar": ["baz"]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz"] })
    true

    # Order is respected
    iex> payload = ~S/{ "foo": 1, "bar": [1, "baz"]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => ["baz", 1] })
    false

Validates lists of objects

    iex> payload = ~S/[{ "foo": 1, "bar": { "baz": 2 }}]/
    iex> Voorhees.matches_payload?(payload, [%{ :foo => 1, "bar" => %{ "baz" => 2 } }])
    true

Validates nested objects

    iex> payload = ~S/{ "foo": 1, "bar": { "baz": 2 }}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => %{ "baz" => 2 } })
    true

Validates nested lists of objects

    iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
    iex> Voorhees.matches_payload?(payload, %{ :foo => 1, "bar" => [%{ "baz" => 2 }] })
    true


### `Voorhees.matches_schema?`

Validating simple objects

    iex> payload = ~S[{ "foo": 1, "bar": "baz" }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"]) # Property names can be strings or atoms
    true

    # Extra keys
    iex> payload = ~S[{ "foo": 1, "bar": "baz", "boo": 3 }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    false

    # Missing keys
    iex> payload = ~S[{ "foo": 1 }]
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    false

Validating lists of objects

    iex> payload = ~S/[{ "foo": 1, "bar": "baz" },{ "foo": 2, "bar": "baz" }]/
    iex> Voorhees.matches_schema?(payload, [:foo, "bar"])
    true


Validating nested lists of objects

    iex> payload = ~S/{ "foo": 1, "bar": [{ "baz": 2 }]}/
    iex> Voorhees.matches_schema?(payload, [:foo, bar: [:baz]])
    true

Validating that a property is a list of scalar values

    iex> payload = ~S/{ "foo": 1, "bar": ["baz", 2]}/
    iex> Voorhees.matches_schema?(payload, [:foo, bar: []])
    true
