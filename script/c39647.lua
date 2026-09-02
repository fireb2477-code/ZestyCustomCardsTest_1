-- Robin - The Star Rail Summeretto
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon standard procedure: 2 Level 12 "Genshin"/"Halovian"/"Star Rail" monsters
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,s.xyzfilter,12,2)

    -- Alternative Xyz Summon procedure: 3 "Halovian"/"Genshin" on field + 2 "Halovian"/"Genshin"/"Star Rail" in hand
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetValue(SUMMON_TYPE_XYZ)
    e0:SetCondition(s.altxyzcon)
    e0:SetTarget(s.altxyztg)
    e0:SetOperation(s.altxyzop)
    c:RegisterEffect(e0)

    -- Protection 1: Cannot be targeted by opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    -- Protection 2: Cannot be destroyed, tributed, banished, or sent to GY by opponent's card effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_UNRELEASABLE_EFF)
    c:RegisterEffect(e3)

    local e4=e2:Clone()
    e4:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e4)

    local e5=e2:Clone()
    e5:SetCode(EFFECT_CANNOT_TO_GRAVE)
    c:RegisterEffect(e5)

    -- On Normal or Special Summon effect
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetTarget(s.sumtg)
    e6:SetOperation(s.sumop)
    c:RegisterEffect(e6)

    local e7=e6:Clone()
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e7)

    -- Quick Effect: Respond to opponent's card effect activation
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,5))
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetCode(EVENT_CHAINING)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1,id)
    e8:SetCondition(s.effcon)
    e8:SetCost(s.effcost)
    e8:SetTarget(s.efftg)
    e8:SetOperation(s.effop)
    c:RegisterEffect(e8)
end

s.listed_series={0x987,0x369,0x986}

-- Hàm kiểm tra lá bài thuộc 1 trong 3 Archetype
function s.is_archetype(c)
    return c:IsSetCard(0x987) or c:IsSetCard(0x369) or c:IsSetCard(0x986)
end

-- Standard Xyz Material Filter
function s.xyzfilter(c,xyz,sumtype,tp)
    return s.is_archetype(c)
end

-- Alternative Xyz Summon Logic
function s.altmfilter_field(c)
    return (c:IsSetCard(0x987) or c:IsSetCard(0x369)) and c:IsCanBeXyzMaterial(nil) and c:IsFaceup()
end
function s.altmfilter_hand(c)
    return s.is_archetype(c) and c:IsCanBeXyzMaterial(nil)
end

function s.altxyzcon(e,c,og,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg_field=Duel.GetMatchingGroup(s.altmfilter_field,tp,LOCATION_MZONE,0,nil)
    local mg_hand=Duel.GetMatchingGroup(s.altmfilter_hand,tp,LOCATION_HAND,0,nil)
    return #mg_field>=3 and #mg_hand>=2 and Duel.GetLocationCountFromEx(tp,tp,mg_field,c)>0
end

function s.altxyztg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
    local mg_field=Duel.GetMatchingGroup(s.altmfilter_field,tp,LOCATION_MZONE,0,nil)
    local mg_hand=Duel.GetMatchingGroup(s.altmfilter_hand,tp,LOCATION_HAND,0,nil)
    if #mg_field<3 or #mg_hand<2 then return false end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg1=mg_field:Select(tp,3,3,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sg2=mg_hand:Select(tp,2,2,nil)
    sg1:Merge(sg2)
    sg1:KeepAlive()
    e:SetLabelObject(sg1)
    return true
end

function s.altxyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
    local g=e:GetLabelObject()
    if not g then return end
    c:SetMaterial(g)
    Duel.Overlay(c,g)
    g:Delete()
end

-- Protection Filter
function s.indval(e,re,rp)
    return rp==1-e:GetHandlerPlayer()
end

-- Summon Effect Logic
function s.sumfilter(c,e,tp)
    return c:IsSetCard(0x987) and c:IsLevel(1) and c:IsRace(RACE_WINGEDBEAST) and c:IsAttack(0)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
        return #g>=3
    end
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.sumfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    if #g<3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local sg=g:Select(tp,3,3,nil)
    if #sg==3 then
        local can_sp = Duel.GetLocationCount(tp,LOCATION_MZONE)>=3 
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and sg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)==3
        local can_th = sg:FilterCount(Card.IsAbleToHand,nil)==3

        local op=0
        if can_sp and can_th then
            op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        elseif can_sp then
            op=0
        else
            op=1
        end

        if op==0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id,4))
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_tp,se)
    return not s.is_archetype(c)
end

-- Quick Effect Logic
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end

function s.costfilter1(c)
    return c:IsSetCard(0x987) and c:IsMonster() and c:IsDiscardable()
end
function s.costfilter2(c)
    return c:IsSetCard(0x987) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,e:GetHandler())
    if chk==0 then return b1 or b2 end

    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
    elseif b1 then
        op=0
    else
        op=1
    end

    if op==0 then
        Duel.DiscardHand(tp,s.costfilter1,1,1,REASON_COST+REASON_DISCARD)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x987) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil)
    local b2=Duel.IsChainNegatable(ev) and re:GetHandler():IsRelateToEffect(re)
    local b3=re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsAbleToRemove()
    local b4=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)

    local off=1
    local ops={}
    local opval={}

    if b1 then ops[off]=aux.Stringid(id,8) opval[off]=0 off=off+1 end
    if b2 then ops[off]=aux.Stringid(id,9) opval[off]=1 off=off+1 end
    if b3 then ops[off]=aux.Stringid(id,10) opval[off]=2 off=off+1 end
    if b4 then ops[off]=aux.Stringid(id,11) opval[off]=3 off=off+1 end

    local op=Duel.SelectOption(tp,table.unpack(ops))+1
    local sel=opval[op]
    e:SetLabel(sel)

    if sel==0 then
        e:SetCategory(CATEGORY_DESTROY)
        local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    elseif sel==1 then
        e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
        Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
        if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
            Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
        end
    elseif sel==2 then
        e:SetCategory(CATEGORY_REMOVE)
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    elseif sel==3 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
    end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    local sel=e:GetLabel()
    if sel==0 then
        local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
        local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)

        local opt=0
        if #g1>0 and #g2>0 then
            opt=Duel.SelectOption(tp,aux.Stringid(id,12),aux.Stringid(id,13))
        elseif #g1>0 then
            opt=0
        elseif #g2>0 then
            opt=1
        else
            return
        end

        if opt==0 then
            local sg=g1:RandomSelect(tp,1)
            Duel.Destroy(sg,REASON_EFFECT)
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=g2:Select(tp,1,1,nil)
            Duel.HintSelection(sg)
            Duel.Destroy(sg,REASON_EFFECT)
        end

    elseif sel==1 then
        if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
            Duel.Destroy(eg,REASON_EFFECT)
        end

    elseif sel==2 then
        local tc=re:GetHandler()
        if tc:IsRelateToEffect(re) and Duel.Banish(tc,POS_FACEUP,REASON_EFFECT)>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetReset(RESET_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetLabelObject(tc)
            e1:SetOperation(s.retop)
            Duel.RegisterEffect(e1,tp)
        end

    elseif sel==3 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc then
        Duel.ReturnToField(tc)
    end
end
