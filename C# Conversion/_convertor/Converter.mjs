
import { splitCodeIntoTokens } from './Lexer.mjs'
import * as Grammar from './Grammar.mjs'
import fs from 'fs'

function isSpace(str) {
    return str.trim().length == 0
}

const hxFolderPath = `E:\\StencylProjects\\stencylworks\\games\\Tilefinder\\code`
const csFolderPath = "E:\\Work\\GitHub\\Tale and Ale\\repo\\C# Conversion"

let fileName = process.argv[2]
const folderName = process.argv[3]

function replacePrimitive(line, fromStr, toStr) {
    if (line.includes(fromStr) == false) {
        return line
    }
    const alphabet = 'qwertyuiopasdfghjklzxcvbnm'
    const strStart = line.indexOf(fromStr)
    if (alphabet.includes(line[strStart])) {
        return line
    }
    line = line.replace(fromStr, toStr)
    return replacePrimitive(line, fromStr, toStr)
}

function replaceLambdas(line) {
    if (line.includes('->') == false) {
        return line
    }

    let indentation = 0
    while (isSpace(line[indentation])) {
        if (line[indentation] == '\t') {
            indentation += 4
        } else {
            indentation++
        }
    }
    const words = line.trim().split(' ')
    
    const newWords = []
    for (const word of words) {
        if (word.includes('->') == false) {
            newWords.push(word)
            continue
        }

        const types = word.split('->')
        const csType = types[types.length - 1] == 'Void' ? 'Action': 'Func'
        
        if (types[types.length - 1] == 'Void') {
            types.pop()
        }

        const fullType = `${csType}<${types.join(', ')}>`
        newWords.push(fullType)
    }
    
    let newLine = newWords.join(' ')
    for (let i = 0; i < indentation; i++) {
        newLine = ' ' + newLine
    }

    return newLine
}

function replaceOneType(line) {
    if (line.includes(':') == false) {
        return line
    }

    const colonI = line.indexOf(':')
    let leftWordStart = colonI - 1
    while (isSpace(line[leftWordStart])) {
        leftWordStart--
    }
    let leftWordEnd = leftWordStart
    let paranthesisStack = 0
    while (true) {
        if (leftWordEnd < 0) {
            break
        }
        if (line[leftWordEnd] == ')') {
            paranthesisStack++
        }
        if (line[leftWordEnd] == '(') {
            paranthesisStack--
            if (paranthesisStack < 0) {
                break
            }
        }
        if (isSpace(line[leftWordEnd])) {
            if (paranthesisStack == 0) {
                break
            }
        }
        if ([';', ',', '->'].includes(line[leftWordEnd])) {
            break
        }
        leftWordEnd--
    }
    leftWordEnd++
    leftWordStart++ // Fix cause they are 1 too much to the 

    let rightWordStart = colonI + 1
    while (isSpace(line[rightWordStart])) {
        rightWordStart++
    }
    let rightWordEnd = rightWordStart
    while (true) {
        if (rightWordEnd >= line.length - 1) {
            break
        }
        if (isSpace(line[rightWordEnd])) {
            break
        }
        if ([';', ',', '->', ')', '('].includes(line[rightWordEnd])) {
            break
        }
        rightWordEnd++
    }

    const leftWord = line.substring(leftWordEnd, leftWordStart)
    const rightWord = line.substring(rightWordStart, rightWordEnd)
    console.log(`${leftWord} -- ${rightWord}`)
    const newLine = line.substring(0, leftWordEnd) + `${rightWord} ${leftWord}` + line.substring(rightWordEnd)

    return newLine.replaceAll(' var ', ' ')
}

function replaceGenerics(line) {
    if (line.includes('<') == false) {
        return line
    }
    let startArrowI = line.indexOf('<')
    if (line[startArrowI-1] == ' ' || line[startArrowI+1] == ' ') {
        return line
    }
    let collectionTypeI = startArrowI
    while (!isSpace(line[collectionTypeI]) && collectionTypeI > 0) {
        collectionTypeI--
    }
    collectionTypeI++

    const collectionType = line.substring(collectionTypeI, startArrowI)
    
    
    let arrowEndI = startArrowI + 1
    let arrowStack = 1
    while (true) {
        if (line[arrowEndI] == '>') {
            arrowStack--
            if (arrowStack == 0) {
                break
            }
        }
        if (line[arrowEndI] == '<') {
            arrowStack++
        }
        arrowEndI++
    }
    const typeParams = line.substring(startArrowI + 1, arrowEndI)

    console.log(collectionType, typeParams)

    if (collectionType == 'Array') {
        console.log('YES')
        return line.substring(0, collectionTypeI) + `${typeParams}[]` + line.substring(arrowEndI + 1)
    }
    console.log('NO')
    return line.substring(0, collectionTypeI) + `${collectionType}<${typeParams}>` + line.substring(arrowEndI + 1)

}




let haxeFile = fs.readFileSync(hxFolderPath + '\\' + fileName + '.hx', 'utf8')

haxeFile = haxeFile.replaceAll(";", ' ;')
haxeFile = haxeFile.replaceAll("'", '"')
haxeFile = haxeFile.replaceAll(" -> ", '->')

haxeFile = haxeFile.replaceAll("Std.Int", 'Math.Floor')

const haxeLines = haxeFile.split('\n')

const csLines = []
for (let line of haxeLines) {

    if (
        line.includes('import') ||
        line.includes('package scripts') ||
        line.includes('using')
    ) {
        continue;
    }

    if (line.trim().length == 0) {
        csLines.push(line)
        continue
    }

    if (line.startsWith('class')) {
        line = "public " + line
    }
    if (line.includes('<')) {
        line = replaceGenerics(line)
    }
    if (line.includes('->')) {
        line = replaceLambdas(line)
    }
    if (line.includes(':')) {
        line = replaceOneType(line)
    }


    line = replacePrimitive(line, 'String', 'string')
    line = replacePrimitive(line, 'Int', 'int')
    line = replacePrimitive(line, 'Float', 'double')
    line = replacePrimitive(line, 'Bool', 'bool')

    csLines.push(line)
}

let csFile = csLines.join('\n')
csFile = csFile.replaceAll(" ;", ';')

const finalFileName = csFolderPath + '\\' + folderName + '\\' + fileName + '.cs'
fs.writeFileSync(finalFileName, csFile, { encoding:'utf8' })