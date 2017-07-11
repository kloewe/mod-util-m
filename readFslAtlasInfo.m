function R = readFslAtlasInfo(fname)
%READFSLATLASINFO Get region info from atlas XML files included with FSL.
%
%   FSL (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) comes with an
%   assortment of atlases (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Atlases).
%
%   The purpose of READFSLATLASINFO is to make the region information
%   contained in FSL's atlas XML files available in Matlab.
%   
%   Example:
%
%     fname = 'HarvardOxford-Cortical-Lateralized.xml'
%     R = READFSLATLASINFO(['/usr/share/fsl/data/atlases/' fname]);
%
%   Author: Kristian Loewe

docNode = xmlread(fname);

import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

expr = xpath.compile('atlas/data/label');
nodeList = expr.evaluate(docNode, XPathConstants.NODESET);
nLabels = nodeList.getLength();

R = cell(1,nLabels);
for iL = 1:nLabels
  R{iL}.label = char(nodeList.item(iL-1).getTextContent());
  R{iL}.index = str2double(nodeList.item(iL-1).getAttribute('index')) + 1;
  R{iL}.x = str2double(nodeList.item(iL-1).getAttribute('x'));
  R{iL}.y = str2double(nodeList.item(iL-1).getAttribute('y'));
  R{iL}.z = str2double(nodeList.item(iL-1).getAttribute('z'));
end

end
