--Robin - The Star Rail Summeretto
local s,id=GetID()

s.listed_series={0x987,0x986,0x369}

function s.initial_effect(c)
	--------------------------------------------------
	-- Xyz Summon
	-- 2 Level 12 "Genshin"/"Halovian"/"Star Rail" monsters
	--------------------------------------------------
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,s.matfilter,12,2)

	--------------------------------------------------
	-- Alternative Xyz Summon
	-- 3 "Halovian"/"Genshin" monsters you control
	-- + 2 "Halovian"/"Genshin"/"Star Rail" monsters
	-- in your hand
	--------------------------------------------------
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.altcon)
	e0:SetTarget(s.alttg)
	e0:SetOperation(s.altop)
	c:RegisterEffect(e0)

	--------------------------------------------------
	-- Cannot be destroyed, Tributed, banished,
	-- or sent to GY by opponent's effects.
	-- Also cannot be targeted by card effects.
	--------------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetValue(s.rmlimit)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e4:SetValue(s.tglimit)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)

	--------------------------------------------------
	-- On Normal/Special Summon:
	-- Special Summon 3 Level 1 Halovian Winged Beast
	-- monsters with 0 ATK
	-- OR add them to hand instead.
	--
	-- After this effect resolves, for the rest of
	-- the Duel, you can only Special Summon
	-- Genshin / Star Rail / Halovian monsters.
	--------------------------------------------------
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)

	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)

	--------------------------------------------------
	-- Quick Effect
	--------------------------------------------------
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(
		CATEGORY_DESTROY+
		CATEGORY_NEGATE+
		CATEGORY_REMOVE+
		CATEGORY_SPECIAL_SUMMON
	)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,id+100)
	e8:SetCondition(s.qcon)
	e8:SetCost(s.qcost)
	e8:SetTarget(s.qtg)
	e8:SetOperation(s.qop)
	c:RegisterEffect(e8)
end


--------------------------------------------------
-- Normal Xyz materials
--------------------------------------------------

function s.matfilter(c,xyzc)
	return c:IsLevel(12)
		and (
			c:IsSetCard(0x987)
			or c:IsSetCard(0x986)
			or c:IsSetCard(0x369)
		)
end


--------------------------------------------------
-- Alternative Xyz material filters
--------------------------------------------------

-- The 3 monsters that must be on the field.
function s.fieldfilter(c)
	return c:IsFaceup()
		and (
			c:IsSetCard(0x987)
			or c:IsSetCard(0x369)
		)
end

-- The 2 monsters that must be in the hand.
function s.handfilter(c)
	return (
		c:IsSetCard(0x987)
		or c:IsSetCard(0x986)
		or c:IsSetCard(0x369)
	)
end


--------------------------------------------------
-- Alternative Xyz Summon condition
--------------------------------------------------

function s.altcon(e,c)
	if c==nil then
		return true
	end

	if not c:IsLocation(LOCATION_EXTRA) then
		return false
	end

	local tp=e:GetHandlerPlayer()

	local fg=Duel.GetMatchingGroup(
		s.fieldfilter,
		tp,
		LOCATION_MZONE,
		0,
		nil
	)

	local hg=Duel.GetMatchingGroup(
		s.handfilter,
		tp,
		LOCATION_HAND,
		0,
		nil
	)

	return #fg>=3 and #hg>=2
end


function s.alttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local fg=Duel.GetMatchingGroup(
			s.fieldfilter,
			tp,
			LOCATION_MZONE,
			0,
			nil
		)

		local hg=Duel.GetMatchingGroup(
			s.handfilter,
			tp,
			LOCATION_HAND,
			0,
			nil
		)

		return #fg>=3 and #hg>=2
	end
end


function s.altop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local fg=Duel.GetMatchingGroup(
		s.fieldfilter,
		tp,
		LOCATION_MZONE,
		0,
		nil
	)

	local hg=Duel.GetMatchingGroup(
		s.handfilter,
		tp,
		LOCATION_HAND,
		0,
		nil
	)

	--------------------------------------------------
	-- Select 3 monsters from field
	--------------------------------------------------

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_XMATERIAL
	)

	local sg1=fg:Select(tp,3,3,nil)

	if #sg1~=3 then
		return
	end

	--------------------------------------------------
	-- Select 2 monsters from hand
	--------------------------------------------------

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_XMATERIAL
	)

	local sg2=hg:Select(tp,2,2,nil)

	if #sg2~=2 then
		return
	end

	--------------------------------------------------
	-- Combine materials
	--------------------------------------------------

	sg1:Merge(sg2)

	if #sg1~=5 then
		return
	end

	--------------------------------------------------
	-- Put all 5 underneath the Xyz monster
	--------------------------------------------------

	Duel.Overlay(c,sg1)
end


--------------------------------------------------
-- Protection
--------------------------------------------------

function s.indes(e,re)
	return re and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


function s.rmlimit(e,re,tp)
	return re and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


function s.tglimit(e,re,tp)
	return re and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end


--------------------------------------------------
-- Level 1 Halovian Winged Beast, 0 ATK
--------------------------------------------------

function s.lv1filter(c)
	return c:IsSetCard(0x987)
		and c:IsLevel(1)
		and c:IsRace(RACE_WINGEDBEAST)
		and c:GetAttack()==0
		and c:IsAbleToHand()
end


function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.lv1filter,
			tp,
			LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,
			0,
			3,
			nil
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_SPECIAL_SUMMON,
		nil,
		3,
		tp,
		LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
	)

	Duel.SetOperationInfo(
		0,
		CATEGORY_TOHAND,
		nil,
		3,
		tp,
		LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
	)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local g=Duel.GetMatchingGroup(
		s.lv1filter,
		tp,
		LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,
		0,
		nil
	)

	if #g<3 then
		return
	end

	--------------------------------------------------
	-- Choose Special Summon OR add to hand
	--------------------------------------------------

	local op=Duel.SelectOption(
		tp,
		aux.Stringid(id,0),
		aux.Stringid(id,1)
	)

	Duel.Hint(
		HINT_SELECTMSG,
		tp,
		HINTMSG_SPSUMMON
	)

	local sg=g:Select(tp,3,3,nil)

	if #sg~=3 then
		return
	end

	if op==0 then
		--------------------------------------------------
		-- Special Summon the 3 monsters
		--------------------------------------------------

		local ct=Duel.SpecialSummon(
			sg,
			0,
			tp,
			tp,
			false,
			false,
			POS_FACEUP
		)

		if ct>0 then
			s.lock(e,tp)
		end
	else
		--------------------------------------------------
		-- Add the 3 monsters to hand
		--------------------------------------------------

		local ct=Duel.SendtoHand(
			sg,
			nil,
			REASON_EFFECT
		)

		if ct>0 then
			Duel.ConfirmCards(
				1-tp,
				sg
			)

			s.lock(e,tp)
		end
	end
end


--------------------------------------------------
-- Lock Special Summons for the rest of the Duel
--------------------------------------------------

function s.lock(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())

	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)

	e1:SetTargetRange(1,0)

	e1:SetTarget(s.locktg)

	Duel.RegisterEffect(e1,tp)
end


function s.locktg(e,c)
	return not (
		c:IsSetCard(0x987)
		or c:IsSetCard(0x986)
		or c:IsSetCard(0x369)
	)
end


--------------------------------------------------
-- Quick Effect condition
--------------------------------------------------

function s.qcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp
		and Duel.IsChainDisablable(ev)
end


--------------------------------------------------
-- Quick Effect cost
--
-- Discard 1 Halovian monster
-- OR send 1 Halovian monster you control
-- to the GY.
--------------------------------------------------

function s.qcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local h=Duel.IsExistingMatchingCard(
		s.halcostfilter,
		tp,
		LOCATION_HAND,
		0,
		1,
		nil
	)

	local f=Duel.IsExistingMatchingCard(
		s.halcostfilter,
		tp,
		LOCATION_MZONE,
		0,
		1,
		nil
	)

	if chk==0 then
		return h or f
	end

	local op

	if h and f then
		op=Duel.SelectOption(
			tp,
			aux.Stringid(id,2),
			aux.Stringid(id,3)
		)
	elseif h then
		op=0
	else
		op=1
	end

	if op==0 then
		Duel.Hint(
			HINT_SELECTMSG,
			tp,
			HINTMSG_DISCARD
		)

		local g=Duel.SelectMatchingCard(
			tp,
			s.halcostfilter,
			tp,
			LOCATION_HAND,
			0,
			1,
			1,
			nil
		)

		Duel.SendtoGrave(
			g,
			REASON_COST+REASON_DISCARD
		)
	else
		Duel.Hint(
			HINT_SELECTMSG,
			tp,
			HINTMSG_TOGRAVE
		)

		local g=Duel.SelectMatchingCard(
			tp,
			s.halcostfilter,
			tp,
			LOCATION_MZONE,
			0,
			1,
			1,
			nil
		)

		Duel.SendtoGrave(
			g,
			REASON_COST
		)
	end
end


function s.halcostfilter(c)
	return c:IsSetCard(0x987)
		and c:IsAbleToGrave()
end


--------------------------------------------------
-- Quick Effect target
--------------------------------------------------

function s.qtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_DESTROY,
		nil,
		1,
		0,
		0
	)
end


--------------------------------------------------
-- Quick Effect operation
--------------------------------------------------

function s.qop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local op=Duel.SelectOption(
		tp,
		aux.Stringid(id,4),
		aux.Stringid(id,5),
		aux.Stringid(id,6),
		aux.Stringid(id,7)
	)

	--------------------------------------------------
	-- 1. Destroy 1 card in hand or opponent's field
	--------------------------------------------------

	if op==0 then
		local g=Duel.GetMatchingGroup(
			s.destroyfilter,
			tp,
			LOCATION_HAND,
			LOCATION_MZONE,
			nil
		)

		if #g==0 then
			return
		end

		Duel.Hint(
			HINT_SELECTMSG,
			tp,
			HINTMSG_DESTROY
		)

		local tc=g:Select(tp,1,1,nil):GetFirst()

		if tc then
			Duel.Destroy(
				tc,
				REASON_EFFECT
			)
		end

	--------------------------------------------------
	-- 2. Negate and destroy
	--------------------------------------------------

	elseif op==1 then
		if Duel.NegateActivation(ev) then
			Duel.Destroy(
				re:GetHandler(),
				REASON_EFFECT
			)
		end

	--------------------------------------------------
	-- 3. Banish until End Phase
	--------------------------------------------------

	elseif op==2 then
		local tc=re:GetHandler()

		if tc and tc:IsRelateToChain() then
			Duel.Remove(
				tc,
				POS_FACEUP,
				REASON_EFFECT+REASON_TEMPORARY
			)

			local e1=Effect.CreateEffect(c)

			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)

			e1:SetCountLimit(1)

			e1:SetLabelObject(tc)

			e1:SetOperation(s.returnop)

			Duel.RegisterEffect(e1,tp)
		end

	--------------------------------------------------
	-- 4. Special Summon 1 Halovian
	--------------------------------------------------

	else
		Duel.Hint(
			HINT_SELECTMSG,
			tp,
			HINTMSG_SPSUMMON
		)

		local g=Duel.SelectMatchingCard(
			tp,
			s.halspfilter,
			tp,
			LOCATION_HAND+LOCATION_DECK+
			LOCATION_GRAVE+LOCATION_REMOVED,
			0,
			1,
			1,
			nil
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


--------------------------------------------------
-- Destroy target
-- Hand of controller OR opponent's field
--------------------------------------------------

function s.destroyfilter(c,tp)
	return c:IsDestructable()
		and (
			c:IsLocation(LOCATION_HAND)
			or (
				c:IsLocation(LOCATION_MZONE)
				and c:IsControler(1-tp)
			)
		)
end


--------------------------------------------------
-- Special Summon Halovian
--------------------------------------------------

function s.halspfilter(c)
	return c:IsSetCard(0x987)
		and c:IsMonster()
		and c:IsCanBeSpecialSummoned(nil,0,TP, false)
end


--------------------------------------------------
-- Return banished card at End Phase
--------------------------------------------------

function s.returnop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()

	if tc and tc:IsLocation(LOCATION_REMOVED) then
		Duel.ReturnToField(tc)
	end

	e:Reset()
end