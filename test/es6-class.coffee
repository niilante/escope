# -*- coding: utf-8 -*-
#  Copyright (C) 2014 Yusuke Suzuki <utatane.tea@gmail.com>
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

expect = require('chai').expect
harmony = require '../third_party/esprima'
escope = require '..'

describe 'ES6 class', ->
    it 'declaration name creates class scope', ->
        ast = harmony.parse """
        class Derived extends Base {
            constructor() {
            }
        }
        new Derived();
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 3

        scope = scopeManager.scopes[0]
        expect(scope.type).to.be.equal 'global'
        expect(scope.block.type).to.be.equal 'Program'
        expect(scope.isStrict).to.be.false
        expect(scope.variables).to.have.length 1
        expect(scope.variables[0].name).to.be.equal 'Derived'
        expect(scope.references).to.have.length 2
        expect(scope.references[0].identifier.name).to.be.equal 'Base'
        expect(scope.references[1].identifier.name).to.be.equal 'Derived'

        scope = scopeManager.scopes[1]
        expect(scope.type).to.be.equal 'class'
        expect(scope.block.type).to.be.equal 'ClassDeclaration'
        expect(scope.isStrict).to.be.true
        expect(scope.variables).to.have.length 1
        expect(scope.variables[0].name).to.be.equal 'Derived'
        expect(scope.references).to.have.length 0

        scope = scopeManager.scopes[2]
        expect(scope.type).to.be.equal 'function'
        expect(scope.block.type).to.be.equal 'FunctionExpression'
        expect(scope.isStrict).to.be.true
        expect(scope.variables).to.have.length 1
        expect(scope.variables[0].name).to.be.equal 'arguments'
        expect(scope.references).to.have.length 0

    it 'expression name creates class scope#1', ->
        ast = harmony.parse """
        (class Derived extends Base {
            constructor() {
            }
        });
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 3

        scope = scopeManager.scopes[0]
        expect(scope.type).to.be.equal 'global'
        expect(scope.block.type).to.be.equal 'Program'
        expect(scope.isStrict).to.be.false
        expect(scope.variables).to.have.length 0
        expect(scope.references).to.have.length 1
        expect(scope.references[0].identifier.name).to.be.equal 'Base'

        scope = scopeManager.scopes[1]
        expect(scope.type).to.be.equal 'class'
        expect(scope.block.type).to.be.equal 'ClassExpression'
        expect(scope.isStrict).to.be.true
        expect(scope.variables).to.have.length 1
        expect(scope.variables[0].name).to.be.equal 'Derived'
        expect(scope.references).to.have.length 0

        scope = scopeManager.scopes[2]
        expect(scope.type).to.be.equal 'function'
        expect(scope.block.type).to.be.equal 'FunctionExpression'

    it 'expression name creates class scope#2', ->
        ast = harmony.parse """
        (class extends Base {
            constructor() {
            }
        });
        """

        scopeManager = escope.analyze ast, ecmaVersion: 6
        expect(scopeManager.scopes).to.have.length 2

        scope = scopeManager.scopes[0]
        expect(scope.type).to.be.equal 'global'
        expect(scope.block.type).to.be.equal 'Program'
        expect(scope.isStrict).to.be.false
        expect(scope.variables).to.have.length 0
        expect(scope.references).to.have.length 1
        expect(scope.references[0].identifier.name).to.be.equal 'Base'

        scope = scopeManager.scopes[1]
        expect(scope.type).to.be.equal 'function'
        expect(scope.block.type).to.be.equal 'FunctionExpression'

# vim: set sw=4 ts=4 et tw=80 :
