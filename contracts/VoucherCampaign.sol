// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title VoucherCampaign - Ví dụ contract theo pattern createX / action(payable) / withdraw
/// @notice Hợp đồng demo cho nhiều campaign gọi vốn/donation, dùng để tham chiếu kiến trúc.
contract VoucherCampaign {
    struct Campaign {
        uint256 id;
        address payable owner;
        string title;
        string description;
        uint256 targetAmount;
        uint256 deadline; // timestamp
        uint256 totalFunded;
        bool withdrawn;
        bool active;
    }

    struct Contribution {
        address contributor;
        uint256 amount;
        uint256 timestamp;
    }

    // Campaign id -> Campaign
    mapping(uint256 => Campaign) public campaigns;
    // Campaign id -> list of contributions
    mapping(uint256 => Contribution[]) public contributions;

    uint256 public nextCampaignId;

    // Events theo pattern
    event CampaignCreated(
        uint256 indexed id,
        address indexed owner,
        string title,
        uint256 targetAmount,
        uint256 deadline
    );

    event CampaignFunded(
        uint256 indexed id,
        address indexed contributor,
        uint256 amount,
        uint256 timestamp
    );

    event CampaignWithdrawn(
        uint256 indexed id,
        address indexed owner,
        uint256 amount,
        uint256 timestamp
    );

    /// @notice Tạo một campaign mới (createX pattern)
    function createCampaign(
        string calldata title,
        string calldata description,
        uint256 targetAmount,
        uint256 duration
    ) external returns (uint256) {
        require(targetAmount > 0, "target > 0");
        require(duration > 0, "duration > 0");

        uint256 id = nextCampaignId++;
        uint256 deadline = block.timestamp + duration;

        campaigns[id] = Campaign({
            id: id,
            owner: payable(msg.sender),
            title: title,
            description: description,
            targetAmount: targetAmount,
            deadline: deadline,
            totalFunded: 0,
            withdrawn: false,
            active: true
        });

        emit CampaignCreated(id, msg.sender, title, targetAmount, deadline);
        return id;
    }

    /// @notice Gửi tiền vào campaign (action(payable) pattern)
    function donate(uint256 campaignId) external payable {
        Campaign storage c = campaigns[campaignId];
        require(c.owner != address(0), "campaign not found");
        require(c.active, "campaign inactive");
        require(block.timestamp <= c.deadline, "campaign ended");
        require(msg.value > 0, "amount > 0");

        c.totalFunded += msg.value;
        contributions[campaignId].push(Contribution({
            contributor: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp
        }));

        emit CampaignFunded(campaignId, msg.sender, msg.value, block.timestamp);
    }

    /// @notice Chủ campaign rút tiền sau khi hết hạn hoặc đạt target (withdraw pattern)
    function withdraw(uint256 campaignId) external {
        Campaign storage c = campaigns[campaignId];
        require(c.owner != address(0), "campaign not found");
        require(msg.sender == c.owner, "only owner");
        require(!c.withdrawn, "already withdrawn");
        require(block.timestamp > c.deadline || c.totalFunded >= c.targetAmount, "not ready");

        c.withdrawn = true;
        c.active = false;
        uint256 amount = c.totalFunded;
        c.totalFunded = 0;

        (bool ok, ) = c.owner.call{value: amount}("");
        require(ok, "transfer failed");

        emit CampaignWithdrawn(campaignId, c.owner, amount, block.timestamp);
    }

    /// @notice Trả về danh sách contribution cho một campaign
    function getContributions(uint256 campaignId) external view returns (Contribution[] memory) {
        return contributions[campaignId];
    }

    /// @notice Helper để lấy thông tin campaign theo id
    function getCampaign(uint256 campaignId) external view returns (Campaign memory) {
        return campaigns[campaignId];
    }

    receive() external payable {}

    fallback() external payable {}
}
