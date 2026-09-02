-- Robin - The Star Rail Sumeretto
-- Custom Card
local s,id=GetID()

s.listed_series={0x987,0x986,0x369}

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Standard Xyz Summon: 2 Level 12 Genshin / Halovian / Star Rail monsters
	Xyz.AddProcedure(c,s.xyzfilter,12,2)

	-- Alternative Xyz Summon Procedure:
	-- 3 Halovian/Genshin monsters on field + 2 Halovian/Genshin/Star Rail monsters in hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetCondition(s.altcon)
	e1:SetTarget(s.alttg)
	e1:SetOperation(s.altop)
	c:RegisterEffect(e1)

	-- Protection 1: Indestructible by opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)

	-- Protection 2: Cannot be targeted by opponent's card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	-- Summon 3 Level 1 Halovian Winged-Beast monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.sumtg)
	e4:SetOperation(s.sumop)
	c:RegisterEffect(e4)

	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

	-- Quick Effect
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetCondition(s.qcon)
	e6:SetTarget(s.qtg)
	e6:SetOperation(s.qop)
	c:RegisterEffect(e6)
end

--------------------------------------------------
-- Standard Xyz materials
--------------------------------------------------

function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsSetCard(0x987) or c:IsSetCard(0x986) or c:IsSetCard(0x369)
end

--------------------------------------------------
-- Alternative Xyz Summon Logic
--------------------------------------------------

function s.fieldmat(c)
	return c:IsFaceup() and (c:IsSetCard(0x987) or c:IsSetCard(0x369)) and c:IsCanBeXyzMaterial(nil)
end

function s.handmat(c)
	return (c:IsSetCard(0x987) or c:IsSetCard(0x986) or c:IsSetCard(0x369)) and c:IsCanBeXyzMaterial(nil)
end

function s.altcon(e,c,og,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg1=Duel.GetMatchingGroup(s.fieldmat,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(s.handmat,tp,LOCATION_HAND,0,nil)
	return #mg1>=3 and #mg2>=2 and Duel.GetLocationCountFromEx(tp,tp,mg1,c)>0
end

function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk,c,og,min,max)
	local mg1=Duel.GetMatchingGroup(s.fieldmat,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(s.handmat,tp,LOCATION_HAND,0,nil)
	if #mg1<3 or #mg2<2 then return false end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=mg1:Select(tp,3,3,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g2=mg2:Select(tp,2,2,nil)

	g1:Merge(g2)
	g1:KeepAlive()
	e:SetLabelObject(g1)
	return true
end

function s.altop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.Overlay(c,g)
	g:Delete()
end

--------------------------------------------------
-- Protection Logic
--------------------------------------------------

function s.indval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end

--------------------------------------------------
-- Summon 3 Halovian monsters Logic
--------------------------------------------------

function s.halovian(c,e,tp)
	return c:IsSetCard(0x987)
		and c:IsLevel(1)
		and c:IsRace(RACE_WINGEDBEAST)
		and c:IsAttack(0)
		and (not e or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.halovian,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		return #g>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.halovian),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if #g<3 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,3,3,nil)

	if #sg==3 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end

	-- Special Summon restriction
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
end

function s.sumlimit(e,c)
	return not (c:IsSetCard(0x987) or c:IsSetCard(0x986) or c:IsSetCard(0x369))
end

--------------------------------------------------
-- Quick Effect Logic
--------------------------------------------------

function s.qcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.qfilter(c)
	return c:IsSetCard(0x987) and c:IsMonster()
end

function s.qtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
end

function s.haloviansummon(c,e,tp)
	return c:IsSetCard(0x987) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.qfilter,tp,LOCATION_MZONE,0,1,nil)

	if not (b1 or b2) then return end

	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=0
	else
		op=1
	end

	-- Discard 1 Halovian from hand or send 1 from field
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(tp,s.qfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)==0 then return end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.qfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	end

	local rc=re:GetHandler()
	local ops={}
	local opval={}
	local off=1

	-- Option 0: Destroy 1 card on opponent's field or hand
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,nil) then
		ops[off]=aux.Stringid(id,5) opval[off]=0 off=off+1
	end
	-- Option 1: Negate and destroy
	if Duel.IsChainNegatable(ev) then
		ops[off]=aux.Stringid(id,6) opval[off]=1 off=off+1
	end
	-- Option 2: Banish
	if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
		ops[off]=aux.Stringid(id,7) opval[off]=2 off=off+1
	end
	-- Option 3: Special Summon Halovian
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.haloviansummon,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) then
		ops[off]=aux.Stringid(id,8) opval[off]=3 off=off+1
	end

	if #ops==0 then return end

	local sel=opval[Duel.SelectOption(tp,table.unpack(ops))+1]

	if sel==0 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_HAND,nil)
		if #g>0 then
			local sg=g:Select(tp,1,1,nil)
			Duel.Destroy(sg,REASON_EFFECT)
		end
	elseif sel==1 then
		if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end
	elseif sel==2 then
		if rc:IsRelateToEffect(re) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	elseif sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.haloviansummon),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
