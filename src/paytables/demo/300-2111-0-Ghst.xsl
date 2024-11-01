<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson,getType,findWinAmount,close">
<lxslt:script lang="javascript">
					

					const crosswordWidth = 11;
					const crosswordHeight = 11;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, idxOfCrossword)
					{
						var scenario = getScenario(jsonContext);
						var crosswords = scenario.split("|");
						var crosswordBoards = [];
						var crosswordLetters = [];
						
						var result = [];						

						for(var numOfCrossword = 0; numOfCrossword &lt; crosswords.length; ++numOfCrossword)
						{
							var crosswordContent = crosswords[numOfCrossword].split(",");
							crosswordBoards[numOfCrossword] = crosswordContent[0];
							crosswordLetters[numOfCrossword] = crosswordContent[1];
							}

						if(idxOfCrossword == 1)
						{	
							result.push(close());
							}

						result.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable"');

						var crosswordLetter = crosswordLetters[idxOfCrossword].split("");
						
						result.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("crossword", translations) + ' ' + (idxOfCrossword+1));
						
						//Drawn Letters
						result.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("drawnLetters", translations));
						result.push('&lt;/td&gt;&lt;/tr&gt;');

						result.push('&lt;tr&gt;');
						for(var idxOfLetter = 0; idxOfLetter &lt; crosswordLetter.length; ++idxOfLetter)
						{

							result.push('&lt;td class="tablebody"&gt;');
							result.push(crosswordLetter[idxOfLetter]);
							result.push('&lt;/td&gt;');
							if(idxOfLetter == (crosswordLetter.length / 2) - 1)
							{
								result.push('&lt;/tr&gt;');
								result.push('&lt;tr&gt;');
							}								
						}
						result.push('&lt;/tr&gt;');
								
						//Words to Match
						result.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("wordToMatch", translations));
						result.push('&lt;/td&gt;&lt;/tr&gt;');

						var crosswordWords = getCrosswordWords(crosswordBoards[idxOfCrossword]);
						var verticalHotWord = findVerticalHotWord(crosswordBoards[idxOfCrossword]);
						var matchCount = 0;

						for(var idxOfWord = 0; idxOfWord &lt; crosswordWords.length; ++idxOfWord)
								{
							result.push('&lt;tr&gt;&lt;td class="tablebody" colspan="' + crosswordLetter.length + '"&gt;');
							var word = crosswordWords[idxOfWord];
							matchChecked = checkMatch(crosswordLetter, word);
							if(matchChecked)
									{
								++matchCount;
								result.push(getTranslationByName("matched", translations) + ': ');
							}

							result.push(word);
							if((idxOfCrossword == 0 &amp;&amp; idxOfWord == 0) || (idxOfCrossword == 1 &amp;&amp; word == verticalHotWord))
										{
								result.push(' ('  + getTranslationByName("hot", translations) + ')');
										}
							result.push('&lt;/td&gt;&lt;/tr&gt;');
										}

						//Prize Results
						result.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("results", translations));
						result.push('&lt;/tr&gt;&lt;/td&gt;');

						//Words Found
						result.push('&lt;tr&gt;&lt;td class="tablebody" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("wordsFound", translations) + ': ');
						result.push(matchCount);
						result.push('&lt;/td&gt;&lt;/tr&gt;');
								
						//Win Amount
						result.push('&lt;tr&gt;&lt;td class="tablebody" colspan="' + crosswordLetter.length + '"&gt;');
						result.push(getTranslationByName("crossword", translations) + ' ' + (idxOfCrossword+1) + ' ' + getTranslationByName("win", translations) + ': ');
						return result.join('');
							}

					function close()
							{
						return '&lt;/td&gt;&lt;/tr&gt;&lt;/table&gt;&lt;br/&gt;';
							}

					function findWinAmount(jsonContext, prizeValues, prizeNames, idxOfCrossword)
							{
						var prizeOfCrosswordBoards = {};
						var prizeValuesArray = prizeValues.slice(1, prizeValues.length).split('|');
						var prizeNamesArray = prizeNames.slice(1, prizeNames.length).split(',');

						var result = 0;
						
						for(var idxOfPrize = 0; idxOfPrize &lt; prizeNamesArray.length; ++idxOfPrize)
						{
							var prizeNameArray = prizeNamesArray[idxOfPrize].split(' ');
						
							if(prizeNameArray[2] == 'Match')
						{	
								prizeOfCrosswordBoards[prizeNameArray[1] + '_' + prizeNameArray[3]] = prizeValuesArray[idxOfPrize];

							}
							else if(prizeNameArray[2] == 'Hot')
							{
								prizeOfCrosswordBoards[prizeNameArray[1] + '_' + prizeNameArray[2]] = prizeValuesArray[idxOfPrize];
							}
								}

						var scenario = getScenario(jsonContext);
						var crosswords = scenario.split("|");
						var crosswordBoards = [];
						var crosswordLetters = [];			

						for(var numOfCrossword = 0; numOfCrossword &lt; crosswords.length; ++numOfCrossword)
								{
							var crosswordContent = crosswords[numOfCrossword].split(",");
							crosswordBoards[numOfCrossword] = crosswordContent[0];
							crosswordLetters[numOfCrossword] = crosswordContent[1];
								}
						var crosswordLetter = crosswordLetters[idxOfCrossword].split("");

						var crosswordWords = getCrosswordWords(crosswordBoards[idxOfCrossword]);
						var verticalHotWord = findVerticalHotWord(crosswordBoards[idxOfCrossword]);
						var matchCount = 0;
						var hotWordMatched= false;
						for(var idxOfWord = 0; idxOfWord &lt; crosswordWords.length; ++idxOfWord)
								{
							var word = crosswordWords[idxOfWord];
							matchChecked = checkMatch(crosswordLetter, word);
							if(matchChecked)
							{
								++matchCount;
								if((idxOfCrossword == 0 &amp;&amp; idxOfWord == 0) || (idxOfCrossword == 1 &amp;&amp; word == verticalHotWord))
								{
									hotWordMatched=true;
								}
							}
						}
						
						if((idxOfCrossword+1) + '_' + matchCount in prizeOfCrosswordBoards)
						{
							result = prizeOfCrosswordBoards[(idxOfCrossword+1) + '_' + matchCount];
							}
						
						if(hotWordMatched &amp;&amp; (idxOfCrossword+1) + '_Hot' in prizeOfCrosswordBoards)
						{
							result += prizeOfCrosswordBoards[(idxOfCrossword+1) + '_Hot'];
							}

						return result+'';
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					function getCrosswordWords(crosswordBoard)
					{
						var crosswordRows = [];
						var crosswordCols = [];
						var lineStringRow = "";
						var lineStringCol = "";
						for(var x = 0; x &lt; crosswordWidth; ++x)
					{
							for(var y = 0; y &lt; crosswordHeight; ++y)
						{
								lineStringRow += crosswordBoard[y + (x * crosswordHeight)];
								lineStringCol += crosswordBoard[x + (y * crosswordWidth)];
							}
							crosswordRows.push(lineStringRow);
							crosswordCols.push(lineStringCol);
							lineStringRow = "";
							lineStringCol = "";
						}

						var crosswordWords = [];						
						for(var i = 0; i &lt; crosswordRows.length; ++i)
							{
							addWords(crosswordRows[i], crosswordWords);
							}
						
						for(var i = 0; i &lt; crosswordCols.length; ++i)
						{
							addWords(crosswordCols[i], crosswordWords);
						}
						
						return crosswordWords;
					}

					function findVerticalHotWord(crosswordBoard)
					{
						var hotWord = [];
						var index = crosswordWidth - 1;

						var letter = crosswordBoard[index];
						
						while(letter != '-')
						{
							hotWord.push(letter); 
							index += crosswordWidth;
							letter = crosswordBoard[index];
						}

						return hotWord.join('');
					}

					function addWords(checkForWords, wordsArray)
					{
						var word = "";
						var count = 0;
						for(var char = 0; char &lt; checkForWords.length; ++char)
						{
							if(checkForWords.charAt(char) != '-')
							{
								word += checkForWords.charAt(char);
							}
							if(checkForWords.charAt(char) == '-' || char + 1 == checkForWords.length)
							{
								if(word.length &gt;= 3)
								{
									wordsArray.push(word);
									count++;
								}
								word = "";
								continue;
							}
						}
					}

					// Input: string of the drawn Letters
					// Output: true all letters of word are in the drawn letters, false if not
					function checkMatch(drawnLetters, word)
					{
						for(var i = 0; i &lt; word.length; ++i)
						{
							if(drawnLetters.indexOf(word[i]) &lt;= -1)
							{
								return false;
							}
						}

						return true;
					}
					
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" &amp;&amp; childNode.getAttribute("key") == keyName)
							{
								//registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='wagerType']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes"/>
</td>
</tr>
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<br/>
<xsl:variable name="prizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, 0)" disable-output-escaping="yes"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="my-ext:findWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 0)"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, 1)" disable-output-escaping="yes"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="my-ext:findWinAmount($odeResponseJson, string($prizeValues), string($prizeNames), 1)"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
<xsl:value-of select="my-ext:close()" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
