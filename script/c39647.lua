--Robin - The Star Rail Sumeretto
--Custom Card
local s,id=GetID()

s.listed_series={0x987,0x986,0x369}

function s.initial_effect(c)
	c:EnableReviveLimit()

	-- Xyz Summon: 2 Level 12 Genshin / Halovian / Star Rail monsters
	Xyz.AddProcedure(c,s.xyzfilter,12,2)

	-- Alternative Xyz Summon:
	-- 3 Halovian/Genshin monsters on the field
	-- + 2 Halovian/Genshin/Star Rail monsters in the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.altcon)
	e1:SetTarget(s.alttg)
	e1:SetOperation(s.altop)
	c:RegisterEffect(e1)

	-- Cannot be destroyed / Tributed / banished / sent to GY by opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)

	-- Summon 3 Level 1 Halovian Winged-Beast monsters
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.sumtg)
	e4:SetOperation(s.sumop)
	c:RegisterEffect(e4)

	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)

	-- Quick Effect
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+2)
	e6:SetCondition(s.qcon)
	e6:SetTarget(s.qtg)
	e6:SetOperation(s.qop)
	c:RegisterEffect(e6)
end

--------------------------------------------------
-- Xyz materials
--------------------------------------------------

function s.xyzfilter(c)
	return c:IsLevel(12)
		and (c:IsSetCard(0x987)
			or c:IsSetCard(0x986)
			or c:IsSetCard(0x369))
end

--------------------------------------------------
-- Alternative Xyz Summon
--------------------------------------------------

function s.altcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(s.fieldmat,tp,LOCATION_MZONE,0,3,nil)
		and Duel.IsExistingMatchingCard(s.handmat,tp,LOCATION_HAND,0,2,nil)
end

function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.fieldmat,tp,LOCATION_MZONE,0,3,nil)
			and Duel.IsExistingMatchingCard(s.handmat,tp,LOCATION_HAND,0,2,nil)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_EXTRA)
end

function s.fieldmat(c)
	return c:IsFaceup()
		and (c:IsSetCard(0x987) or c:IsSetCard(0x369))
end

function s.handmat(c)
	return c:IsSetCard(0x987)
		or c:IsSetCard(0x986)
		or c:IsSetCard(0x369)
end

function s.altop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if Duel.GetLocationCountFromEx(tp)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)

	local g1=Duel.SelectMatchingCard(
		tp,s.fieldmat,tp,LOCATION_MZONE,0,3,3,nil
	)

	if #g1~=3 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)

	local g2=Duel.SelectMatchingCard(
		tp,s.handmat,tp,LOCATION_HAND,0,2,2,nil
	)

	if #g2~=2 then return end

	local mat=g1+g2

	-- Send field materials to GY
	Duel.SendtoGrave(g1,REASON_MATERIAL+REASON_XYZ)

	-- Send hand materials to GY
	Duel.SendtoGrave(g2,REASON_MATERIAL+REASON_XYZ)

	-- Special Summon from Extra Deck
	if Duel.SpecialSummon(
		c,
		SUMMON_TYPE_XYZ,
		tp,
		tp,
		false,
		false,
		POS_FACEUP
	)>0 then
		c:SetMaterial(mat)
	end
end

--------------------------------------------------
-- Protection
--------------------------------------------------

function s.indval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

--------------------------------------------------
-- Summon 3 Halovian monsters
--------------------------------------------------

function s.halovian(c)
	return c:IsSetCard(0x987)
		and c:IsLevel(1)
		and c:IsRace(RACE_WINGEDBEAST)
		and c:IsAttack(0)
		and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(
		s.halovian,
		tp,
		LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		nil
	)

	if chk==0 then
		return #g>=3
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		nil,
		3,
		tp,
		LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
	)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(
		s.halovian,
		tp,
		LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		nil
	)

	if #g<3 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,3,3,nil)

	if #sg==3 then
		Duel.SpecialSummon(
			sg,
			0,
			tp,
			tp,
			false,
			false,
			POS_FACEUP
		)
	end

	-- Special Summon restriction for the rest of the Duel
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
end

function s.sumlimit(e,c)
	return not (
		c:IsSetCard(0x987)
		or c:IsSetCard(0x986)
		or c:IsSetCard(0x369)
	)
end

--------------------------------------------------
-- Quick Effect
--------------------------------------------------

function s.qcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		and Duel.IsChainDisablable(ev)
end

function s.qfilter(c)
	return c:IsSetCard(0x987)
		and c:IsMonster()
end

function s.qtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.qfilter,tp,LOCATION_HAND,0,1,nil
		)
		or Duel.IsExistingMatchingCard(
			s.qfilter,tp,LOCATION_MZONE,0,1,nil
		)
	end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
end

function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local b1=Duel.IsExistingMatchingCard(
		s.qfilter,tp,LOCATION_HAND,0,1,nil
	)

	local b2=Duel.IsExistingMatchingCard(
		s.qfilter,tp,LOCATION_MZONE,0,1,nil
	)

	if not (b1 or b2) then return end

	local op

	if b1 and b2 then
		op=Duel.SelectOption(
			tp,
			aux.Stringid(id,2),
			aux.Stringid(id,3)
		)
	elseif b1 then
		op=0
	else
		op=1
	end

	-- Discard 1 Halovian
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(
			tp,s.qfilter,tp,LOCATION_HAND,0,1,1,nil
		)

		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		else
			return
		end

	-- Send 1 Halovian you control to GY
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(
			tp,s.qfilter,tp,LOCATION_MZONE,0,1,1,nil
		)

		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		else
			return
		end
	end

	if not Duel.IsChainDisablable(ev) then return end

	local rc=re:GetHandler()

	local choices={}

	-- Destroy
	if rc:IsRelateToEffect(re) and rc:IsDestructable() then
		table.insert(choices,0)
	end

	-- Negate + destroy
	table.insert(choices,1)

	-- Banish until End Phase
	if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
		table.insert(choices,2)
	end

	-- Special Summon Halovian
	if Duel.IsExistingMatchingCard(
		s.haloviansummon,
		tp,
		LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		1,nil
	) then
		table.insert(choices,3)
	end

	if #choices==0 then return end

	local op=Duel.SelectOption(tp,
		aux.Stringid(id,4),
		aux.Stringid(id,5),
		aux.Stringid(id,6),
		aux.Stringid(id,7)
	)

	if op==0 then
		if rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end

	elseif op==1 then
		if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end

	elseif op==2 then
		if rc:IsRelateToEffect(re) then
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end

	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

		local g=Duel.SelectMatchingCard(
			tp,
			s.haloviansummon,
			tp,
			LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
			0,
			1,1,nil
		)

		if #g>0 then
			Duel.SpecialSummon(
				g,
				0,
				tp,
				tp,
				false,
				false,
				POS_FACEUP
			)
		end
	end
end

function s.haloviansummon(c)
	return c:IsSetCard(0x987)
		and c:IsMonster()
		and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end