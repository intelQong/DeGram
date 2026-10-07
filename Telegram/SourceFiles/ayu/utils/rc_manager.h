// This is the source code of AyuGram for Desktop, modified for DeGram.
//
// We do not and cannot prevent the use of our code,
// but be respectful and credit the original author.
//
// Copyright @Radolyn, 2026
#pragma once

#include "ayu/data/entities.h"

#include <QtNetwork/QNetworkReply> // kept: other headers rely on it transitively

extern std::unordered_set<ID> default_developers;
extern std::unordered_set<ID> default_channels;

struct CustomBadge
{
	EmojiStatusId emojiStatusId;
	QString text;
};

// DeGram: offline only. AyuGram fetched these lists from
// update.ayugram.one / api.exteragram.app; DeGram uses the built-in defaults.
class RCManager final
{
public:
	static RCManager &getInstance() {
		static RCManager instance;
		return instance;
	}

	RCManager(const RCManager &) = delete;
	RCManager &operator=(const RCManager &) = delete;

	[[nodiscard]] const std::unordered_set<ID> &developers() const {
		return default_developers;
	}

	[[nodiscard]] const std::unordered_set<ID> &channels() const {
		return default_channels;
	}

	[[nodiscard]] const std::unordered_set<ID> &supporters() const {
		return _empty;
	}

	[[nodiscard]] const std::unordered_set<ID> &supporterChannels() const {
		return _empty;
	}

	[[nodiscard]] const std::unordered_map<ID, CustomBadge> &supporterCustomBadges() const {
		return _customBadges;
	}

	[[nodiscard]] QString donateUsername() const {
		return QString("@redditOwner");
	}

	[[nodiscard]] QString donateAmountUsd() const {
		return QString("5.00");
	}

	[[nodiscard]] QString donateAmountTon() const {
		return QString("3.50");
	}

	[[nodiscard]] QString donateAmountRub() const {
		return QString("386");
	}

private:
	RCManager() = default;

	const std::unordered_set<ID> _empty;
	const std::unordered_map<ID, CustomBadge> _customBadges;

};
