<?xml version="1.0" encoding="UTF-8"?><!-- Copyright 2012 predic8 GmbH, www.predic8.com Licensed under the Apache 	License, Version 2.0 (the "License"); you may not use this file except in 	compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 	Unless required by applicable law or agreed to in writing, software distributed 	under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES 	OR CONDITIONS OF ANY KIND, either express or implied. See the License for 	the specific language governing permissions and limitations under the License. --><xsl:stylesheet version="2.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	<xsl:output method="html" indent="yes" encoding="UTF-8" />	<xsl:template match="/">		<html>			<head>				<title>WSDL Diff Generator</title>				<link rel="stylesheet" type="text/css" href="web/a.css" />				<link href="web/jquery.treeview.css" rel="stylesheet" />				<script type="text/javascript" src="web/jquery.js" />				<script type="text/javascript" src="web/jquery.treeview.js" />				<script type="text/javascript">					$(document).ready(function(){					$("#diffs").treeview();					});				</script>			</head>			<body>				<div class="container">					<h1>WSDL Diff Result</h1>					<table class="table table-striped table-bordered">						<thead>							<tr>								<th>Document</th>								<th>TargetNamespace</th>							</tr>						</thead>						<tbody>							<tr>								<td>									<a href="{/WSDLDiff/Original/URL}">Original</a>								</td>								<td>									<xsl:value-of select="/WSDLDiff/Original/TargetNamespace" />								</td>							</tr>							<tr>								<td>									<a href="{/WSDLDiff/Modified/URL}">Modified</a>								</td>								<td>									<xsl:value-of select="/WSDLDiff/Modified/TargetNamespace" />								</td>							</tr>						</tbody>					</table>					<xsl:apply-templates select="/WSDLDiff/OperationChangesInPortType" />					<xsl:apply-templates select="/WSDLDiff/Diffs" />					<div class="footer">						<br />						<p>							Created with							<a href="http://membrane-soa.org/soa-model/?ana">Membrane SOA Model</a>							<br />							Copyright © 2008-2013							<a href="http://www.predic8.com/">predic8 GmbH</a>							<br />							Email:							<a href="mailto:info@predic8.com">info@predic8.com</a>						</p>						<br />					</div>				</div>			</body>		</html>	</xsl:template>	<xsl:template match="OperationChangesInPortType">	  <h2>Operations in portType: <xsl:value-of select="@name"/></h2>		<table class="table table-striped table-bordered">			<thead>				<tr>					<th>Operations</th>					<th>Messages</th>					<th>Modifications</th>					<th>Compatibility</th>				</tr>			</thead>			<tbody>				<xsl:apply-templates />			</tbody>		</table>	</xsl:template>	<xsl:template match="OperationChangesInPortType/Operation">		<tr>			<td rowspan="2">				<xsl:value-of select="@name" />				<xsl:text> </xsl:text>				<xsl:if test="added">					<img src="web/images/add.png" title="Operation has been added to the modified wsdl" />				</xsl:if>				<xsl:if test="removed">					<img src="web/images/remove.png" title="Operation has been removed from the original wsdl" />				</xsl:if>			</td>			<xsl:call-template name="portTypeMessage">				<xsl:with-param name="ptm" select="input" />				<xsl:with-param name="opName" select="@name" />			</xsl:call-template>		</tr>		<tr>			<xsl:call-template name="portTypeMessage">				<xsl:with-param name="ptm" select="output" />				<xsl:with-param name="opName" select="@name" />			</xsl:call-template>		</tr>	</xsl:template>	<xsl:template name="portTypeMessage">		<xsl:param name="ptm" />		<xsl:param name="opName" />		<td>			<xsl:if test="local-name($ptm)= 'input'">				<img src="web/images/request.png" title="Input Message" />			</xsl:if>			<xsl:if test="local-name($ptm)= 'output'">				<img src="web/images/response.png" title="Output Message" />			</xsl:if>			<xsl:text> </xsl:text>			<xsl:value-of select="$ptm/@message" />		</td>		<td>			<xsl:element name="a">				<xsl:attribute name="href">					<xsl:value-of					select="concat('operations/', $opName , '-' ,local-name($ptm), '.html')" />				</xsl:attribute>				<xsl:value-of select="$ptm/@compatibility" />			</xsl:element>		</td>		<td>			<xsl:if test="added">				<img src="web/images/lightning.png" title="Not exist in the original interface." />			</xsl:if>			<xsl:if test="removed">				<img src="web/images/lightning.png" title="Removed from the original interface." />			</xsl:if>			<xsl:if test="not(removed) and not(added)">				<xsl:call-template name="compatibility">					<xsl:with-param name="value" select="$ptm/@compatibility" />				</xsl:call-template>			</xsl:if>		</td>	</xsl:template>	<xsl:template name="compatibility">		<xsl:param name="value" />		<xsl:if test="$value = ''">			<img src="web/images/tick.png" title="The original interface has not changed" />		</xsl:if>		<xsl:if test="$value = 'safe'">			<img src="web/images/tick.png" title="The original interface is still valid" />		</xsl:if>		<xsl:if test="$value = 'breaking'">			<img src="web/images/lightning.png" title="The changes invalidate the original interface" />		</xsl:if>		<xsl:if test="$value = 'not clear'">			<img src="web/images/warning.png"				title="It is not clear if the original inteface is still valid or not" />		</xsl:if>	</xsl:template>	<xsl:template match="Diffs">		<xsl:choose>			<xsl:when test="not(./Diff)">				<h2>There are no differences.</h2>			</xsl:when>			<xsl:otherwise>				<div>					<h2>Differences:</h2>					<xsl:if test="//@breaks = 'true'">						<div class="notice">							<img src="web/images/lightning.png" />							<span>The changes break the interface.</span>						</div>					</xsl:if>					<div>						<ul id="diffs" class="treeview">							<xsl:apply-templates select="Diff" />						</ul>					</div>				</div>				<div class="legend">					<p>These symbols indicate that:</p>					<ul style="list-style-type: none;">						<li>							<img src="web/images/add.png" />							: Element has been added to the modified wsdl.						</li>						<li>							<img src="web/images/remove.png" />							: Element has been removed from the original wsdl.						</li>						<li>							<img src="web/images/tick.png" />							: The change will not influence the interface.						</li>						<li>							<img src="web/images/lightning.png" />							: The change will invalidate the interface.						</li>						<li>							<img src="web/images/request.png" />							: The change is related to the request message.						</li>						<li>							<img src="web/images/response.png" />							: The change is related to the response message.						</li>						<li>							<img src="web/images/fault.png" />							: The change is related to a fault message.						</li>					</ul>				</div>			</xsl:otherwise>		</xsl:choose>	</xsl:template>	<xsl:template match="Diff">		<ul>			<li>				<div>					<xsl:if test="@safe = 'true'">						<img src="web/images/tick.png" title="This change will not influence the interface" />					</xsl:if>					<xsl:if test="@breaks = 'true'">						<img src="web/images/lightning.png" title="This change will invalidate the interface" />					</xsl:if>					<xsl:if test="contains(Description, 'added')">						<img src="web/images/add.png" title="This element has been added to the modified wsdl" />					</xsl:if>					<xsl:if test="contains(Description, 'removed')">						<img src="web/images/remove.png"							title="This element has been removed from the original wsdl" />					</xsl:if>					<xsl:value-of select="Description" />					<xsl:choose>						<xsl:when test="contains(@exchange, 'requestresponse')">							<span class='requestresponse'>								<img src="web/images/request.png" title="This change is related to the request message" />								<img src="web/images/response.png" title="This change is related to the response message" />							</span>						</xsl:when>						<xsl:when test="contains(@exchange, 'request')">							<span class='request'>								<img src="web/images/request.png" title="This change is related to the request message" />							</span>						</xsl:when>						<xsl:when test="contains(@exchange, 'response')">							<span class='response'>								<img src="web/images/response.png" title="This change is related to the response message" />							</span>						</xsl:when>					</xsl:choose>				</div>				<xsl:apply-templates select="Diff" />			</li>		</ul>	</xsl:template></xsl:stylesheet>