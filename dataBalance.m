function [features, targets] = dataBalance(fileName)

file=load(fileName);

FeatVectSel=file.FeatVectSel;
Trg=file.Trg;

ipreIc=[];
iIc=[];
iposIc=[];
irandoms=[];

i=1;
while i<size(FeatVectSel,1)
    Ic=[];
    if Trg(i)==1
        irandoms=[irandoms i-600:i-1];
        while Trg(i)==1      
            Ic=[Ic i];
            i=i+1;
        end
        irandoms=[irandoms Ic];
        irandoms=[irandoms i:i+300];
        i=i+201;        
    elseif Trg(i)==0      
        i=i+1;   
    end
end


i=1;
iIntTotal=[];
ifeatures=[];
targets=[];
while i<size(FeatVectSel,1)
    iIc=[];
    iInt=[];
    j=0;
    if Trg(i)==1
        ipreIc=[i-300:i-1]; % janela 300 fixa
        while Trg(i)==1      
            iIc=[iIc i];
            i=i+1;
        end
        iposIc=[i:i+250]; % janela 250 fixa
        i=i+201;
        while j<(length(ipreIc)+length(iIc)+length(iposIc))
            random=randi(size(FeatVectSel,1));
            if ismember(random,irandoms)== 0
                if ismember(random,iIntTotal)== 0
                    iInt=[iInt random];
                    j=j+1;
                end
            end 
        end
        iIntTotal=[iIntTotal iInt];

        ifeatures=[ifeatures iInt ipreIc iIc iposIc];
        
        IntTarget=repmat([1;0;0;0], 1, length(iInt));
        preIcTarget=repmat([0;1;0;0], 1, length(ipreIc));
        IcTarget=repmat([0;0;1;0], 1, length(iIc));
        posIcTarget=repmat([0;0;0;1], 1, length(iposIc));       

        targets=[targets IntTarget preIcTarget IcTarget posIcTarget];    
    
    elseif Trg(i)==0
        i=i+1; 
    end 
end

features=[];

for i=1:size(ifeatures,2)
    
    features=[features; FeatVectSel(ifeatures(i),:)];
    
end

features=features.';

end