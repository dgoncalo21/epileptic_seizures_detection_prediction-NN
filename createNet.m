function createNet(filename,architecture, structureVetor, activationFunction,learningFunction, trainningFunction, onevsall, goal)

[features, targets] = dataBalance(filename);

if strcmp(architecture,'FeedForward')
    net =feedforwardnet(structureVetor,trainningFunction);                                 
elseif strcmp(architecture,'Recurrent')
    net =layrecnet(1:2,structureVetor,trainningFunction);   
end

net.divideFcn = 'dividerand';        

for i=1:size(structureVetor,2)
	net.layers{i}.transferFcn=activationFunction;    
end           

net.performParam.lr = 0.01;
net.trainParam.goal = 1e-6;
net.divideParam.trainRatio = 70/100;        
net.divideParam.testRatio = 30/100;
% net.trainParam.show = 40;          
net.trainParam.epochs = 1000;
net.trainParam.min_grad = 10e-6;
% net.performFcn='mse';
net.trainParam.max_fail = 200;   

if strcmp(goal,'Detect')
    vetor=[0;0;1;0];
elseif strcmp(goal,'Predict')
    vetor=[0;1;0;0];
end

if strcmp(onevsall,'Yes')
    
	targetsall=[];
    for i=1:size(targets,2)
        if isequal(vetor,targets(:,i))
            targetsall=[targetsall [1;0]];
        else
            targetsall=[targetsall [0;1]];
        end
    end 
    
elseif strcmp(onevsall,'No')
    
	ew=[];

    for i=1:size(targets,2)
        if isequal(targets(:,i),vetor)
            ew=[ew 1];
        else
            ew=[ew 0.6];
        end
    end
end
  
if strcmp(onevsall,'Yes')
    
	if strcmp(trainningFunction,'trainc')
        net.inputweights{:,:}.learnFcn=learningFunction;
        net = train(net,features,targetsall);
    elseif strcmp(trainningFunction,'trainr')
        net.inputweights{:,:}.learnFcn=learningFunction;
        net = train(net,features,targetsall);
    else
        net = train(net,features,targetsall,'useGPU','yes');
    end
    
elseif strcmp(onevsall,'No')
    
	if strcmp(trainningFunction,'trainc')
        net.inputweights{:,:}.learnFcn=learningFunction;
        net = train(net,features,targets,[],[],ew);
    elseif strcmp(trainningFunction,'trainr')
        net.inputweights{:,:}.learnFcn=learningFunction;
        net = train(net,features,targets,[],[],ew);
    else
        net = train(net,features,targets,[],[],ew,'useGPU','yes');
    end
    
end
%% train results
Y = net(features,'useGPU','yes');
%% predict 

pTP=0;
pFN=0;
pTN=0;
pFP=0;
results = [];

if size(Y,1)==2 %1vsall
    
    for i=1:size(Y,2) 
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0]]; 
       else
           results=[results [0;1]]; 
       end
    end
    
	targetsall=[];
    for i=1:size(targets,2)
        if isequal([0;1;0;0],targets(:,i))
            targetsall=[targetsall [1;0]];
        else
            targetsall=[targetsall [0;1]];
        end
    end
    
    for i=1:size(Y,2)
        if isequal(targetsall(:,i),results(:,i))
            if isequal(results(:,i),[1;0])
                pTP=pTP+1;
            else
                pTN=pTN+1;
            end
        else
            if isequal(results(:,i),[1;0])==0
                pFN=pFN+1;
            else
                pFP=pFP+1;
            end
        end    
    end

    psensitivity=(pTP/(pTP+pFN))*100;
    pspecificity=(pTN/(pTN+pFP))*100;
    
elseif size(Y,1)==4   %erros
    
    for i=1:size(Y,2)
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0;0;0]]; 
       elseif findster==2
           results=[results [0;1;0;0]]; 
       elseif findster==3
           results=[results [0;0;1;0]]; 
       elseif findster==4
           results=[results [0;0;0;1]]; 
       end
    end    
    
    for i=1:size(Y,2)
        if isequal(targets(:,i),results(:,i))
            if isequal(results(:,i),[0;1;0;0])
                pTP=pTP+1;
            else
                pTN=pTN+1;
            end
        else
            if isequal(results(:,i),[0;1;0;0])==0
                pFN=pFN+1;
            else
                pFP=pFP+1;
            end
        end    
    end

    psensitivity=(pTP/(pTP+pFN))*100;
    pspecificity=(pTN/(pTN+pFP))*100;
    
end




%% predict 5/10

p510TP=0;
p510FN=0;
p510TN=0;
p510FP=0;

results = [];

if size(Y,1)==2 %1vsall
    
    for i=1:size(Y,2) 
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0]]; 
       else
           results=[results [0;1]]; 
       end
    end
    
	targetsall=[];
    for i=1:size(targets,2)
        if isequal([0;1;0;0],targets(:,i))
            targetsall=[targetsall [1;0]];
        else
            targetsall=[targetsall [0;1]];
        end
    end
    
	for i=10:size(results,2)  % 5/10
     contador=0;
     for j=i-9:i
         if isequal(results(:,j),[1;0])
             contador=contador+1;
         end
     end
        if contador>=5
             for j=i-9:i
                results(:,j)=[1;0];
             end
        end
            i=i+10;
	end
    
    
    for i=1:size(Y,2)
        if isequal(targetsall(:,i),results(:,i))
            if isequal(results(:,i),[1;0])
                p510TP=p510TP+1;
            else
                p510TN=p510TN+1;
            end
        else
            if isequal(results(:,i),[1;0])==0
                p510FN=p510FN+1;
            else
                p510FP=p510FP+1;
            end
        end    
    end

    p510sensitivity=(p510TP/(p510TP+p510FN))*100;
    p510specificity=(p510TN/(p510TN+p510FP))*100;
    
elseif size(Y,1)==4   %erros
    
    for i=1:size(Y,2)
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0;0;0]]; 
       elseif findster==2
           results=[results [0;1;0;0]]; 
       elseif findster==3
           results=[results [0;0;1;0]]; 
       elseif findster==4
           results=[results [0;0;0;1]]; 
       end
    end
    
	for i=10:size(results,2)  % 5/10
     contador=0;
     for j=i-9:i
         if isequal(results(:,j),[0;1;0;0])
             contador=contador+1;
         end
     end
        if contador>=5
             for j=i-9:i
                results(:,j)=[0;1;0;0];
             end
        end
            i=i+10;
	end
    
    
    for i=1:size(Y,2)
        if isequal(targets(:,i),results(:,i))
            if isequal(results(:,i),[0;1;0;0])
                p510TP=p510TP+1;
            else
                p510TN=p510TN+1;
            end
        else
            if isequal(results(:,i),[0;1;0;0])==0
                p510FN=p510FN+1;
            else
                p510FP=p510FP+1;
            end
        end    
    end

    p510sensitivity=(p510TP/(p510TP+p510FN))*100;
    p510specificity=(p510TN/(p510TN+p510FP))*100;
    
end


%% detect

dTP=0;
dFN=0;
dTN=0;
dFP=0;

results = [];

if size(Y,1)==2 %1vsall
    
    for i=1:size(Y,2) 
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0]]; 
       else
           results=[results [0;1]]; 
       end
    end
    
	targetsall=[];
    for i=1:size(targets,2)
        if isequal([0;0;1;0],targets(:,i))
            targetsall=[targetsall [1;0]];
        else
            targetsall=[targetsall [0;1]];
        end
    end
    
    for i=1:size(Y,2)
        if isequal(targetsall(:,i),results(:,i))
            if isequal(results(:,i),[1;0])
                dTP=dTP+1;
            else
                dTN=dTN+1;
            end
        else
            if isequal(results(:,i),[1;0])==0
                dFN=dFN+1;
            else
                dFP=dFP+1;
            end
        end    
    end

    dsensitivity=(dTP/(dTP+dFN))*100;
    dspecificity=(dTN/(dTN+dFP))*100;
    
elseif size(Y,1)==4   %erros
    
    for i=1:size(Y,2)
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0;0;0]]; 
       elseif findster==2
           results=[results [0;1;0;0]]; 
       elseif findster==3
           results=[results [0;0;1;0]]; 
       elseif findster==4
           results=[results [0;0;0;1]]; 
       end
    end    
    
    for i=1:size(Y,2)
        if isequal(targets(:,i),results(:,i))
            if isequal(results(:,i),[0;0;1;0])
                dTP=dTP+1;
            else
                dTN=dTN+1;
            end
        else
            if isequal(results(:,i),[0;0;1;0])==0
                dFN=dFN+1;
            else
                dFP=dFP+1;
            end
        end    
    end

    dsensitivity=(dTP/(dTP+dFN))*100;
    dspecificity=(dTN/(dTN+dFP))*100;
    
end





%% detect 5/10

d510TP=0;
d510FN=0;
d510TN=0;
d510FP=0;

results = [];

if size(Y,1)==2 %1vsall
    
    for i=1:size(Y,2) 
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0]]; 
       else
           results=[results [0;1]]; 
       end
    end
    
	targetsall=[];
    for i=1:size(targets,2)
        if isequal([0;0;1;0],targets(:,i))
            targetsall=[targetsall [1;0]];
        else
            targetsall=[targetsall [0;1]];
        end
    end
    
	for i=10:size(results,2)  % 5/10
     contador=0;
     for j=i-9:i
         if isequal(results(:,j),[1;0])
             contador=contador+1;
         end
     end
        if contador>=5
             for j=i-9:i
                results(:,j)=[1;0];
             end
        end
            i=i+10;
    end
    
    for i=1:size(Y,2)
        if isequal(targetsall(:,i),results(:,i))
            if isequal(results(:,i),[1;0])
                d510TP=d510TP+1;
            else
                d510TN=d510TN+1;
            end
        else
            if isequal(results(:,i),[1;0])==0
                d510FN=d510FN+1;
            else
                d510FP=d510FP+1;
            end
        end    
    end

    d510sensitivity=(d510TP/(d510TP+d510FN))*100;
    d510specificity=(d510TN/(d510TN+d510FP))*100;
    
elseif size(Y,1)==4   %erros
    
    for i=1:size(Y,2)
       valor = Y(:,i);
       maxvalor= max(valor);
       findster = find(valor==maxvalor);
       if findster==1
           results=[results [1;0;0;0]]; 
       elseif findster==2
           results=[results [0;1;0;0]]; 
       elseif findster==3
           results=[results [0;0;1;0]]; 
       elseif findster==4
           results=[results [0;0;0;1]]; 
       end
    end
    
	for i=10:size(results,2)  % 5/10
     contador=0;
     for j=i-9:i
         if isequal(results(:,j),[0;0;1;0])
             contador=contador+1;
         end
     end
        if contador>=5
             for j=i-9:i
                results(:,j)=[0;0;1;0];
             end
        end
            i=i+10;
	end
    
    
    for i=1:size(Y,2)
        if isequal(targets(:,i),results(:,i))
            if isequal(results(:,i),[0;0;1;0])
                d510TP=d510TP+1;
            else
                d510TN=d510TN+1;
            end
        else
            if isequal(results(:,i),[0;0;1;0])==0
                d510FN=d510FN+1;
            else
                d510FP=d510FP+1;
            end
        end    
    end

    d510sensitivity=(d510TP*1.0/(d510TP+d510FN)*1.0)*100;
    d510specificity=(d510TN*1.0/(d510TN+d510FP)*1.0)*100;
    
end
displayResults (psensitivity, pspecificity, p510sensitivity, p510specificity, dsensitivity, dspecificity, d510sensitivity, d510specificity);

save(fullfile('nn','Costum.mat'),'net');
fprintf('Costum.mat saved in nn folder');
fprintf('\n');

end