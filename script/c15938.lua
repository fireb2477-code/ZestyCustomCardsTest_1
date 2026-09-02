-- The Stage of Infinite Delight
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Treat as "Halovian" card
    c:AddSetcodesRule(id,false,0x987)

    -- E1: Search 1 (or 2 and discard 1) "Halovian" card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- E2: (Quick Effect) Reveal or bounce Level 1 Halovian Winged Beast with 0 ATK to destroy 1 card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

s.listed_series={0x987}

-- Filter: Level 1 Halovian Winged Beast monster with 0 ATK
function s.cfilter(c)
    return c:IsFaceup() and c:IsLevel(1) and c:IsSetCard(0x987) and c:IsRace(RACE_WINGEDBEAST) and c:IsAttack(0)
end

function s.thfilter(c)
    return c:IsSetCard(0x987) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g==0 then return end

    local has_mon=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
    if has_mon and #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        -- Add 2 cards and discard 1
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,2,2,nil)
        if #sg==2 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,sg)
            Duel.ShuffleHand(tp)
            Duel.BreakEffect()
            Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
        end
    else
        -- Add 1 card
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end

-- E2 Cost Filters
function s.costfilter1(c)
    return c:IsLevel(1) and c:IsSetCard(0x987) and c:IsRace(RACE_WINGEDBEAST) and c:IsAttack(0) and not c:IsPublic()
end
function s.costfilter2(c)
    return c:IsFaceup() and c:IsLevel(1) and c:IsSetCard(0x987) and c:IsRace(RACE_WINGEDBEAST) and c:IsAttack(0) and c:IsAbleToHandAsCost()
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.costfilter1,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,3))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
    end
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g=Duel.SelectMatchingCard(tp,s.costfilter1,tp,LOCATION_HAND,0,1,1,nil)
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleHand(tp)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_COST)
    end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
