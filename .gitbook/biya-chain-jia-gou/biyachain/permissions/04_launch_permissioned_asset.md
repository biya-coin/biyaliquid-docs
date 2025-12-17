---
sidebar_position: 4
title: 如何启动权限资产
---

# 如何启动权限资产

权限资产可以使用 [Biya Chain APIs/SDKs](https://api.biyachain.exchange/#permissions) 或 Biya Chain CLI `biyachaind` 启动。有关使用 Biya Chain CLI 的更多信息，请参见 https://docs.biyachain.network/toolkits/biyachaind。

```bash
biyachaind tx permissions [command]
```

- 通过 CLI 有四个交易命令可用：
    - `create-namespace`
        - 用于从 JSON 文件为 `TokenFactory` 代币单位创建权限命名空间
        - 创建命名空间时，地址必须是同一 `TokenFactory` 代币单位的管理员。否则无法启动命名空间
    - `update-namespace`
        - 用于更新命名空间参数，包括：
            - 合约钩子
            - 角色权限
            - 角色管理器
            - 策略状态
            - 策略管理器
        - 命名空间更新是增量的，因此除非在 JSON 中明确说明更改，否则现有状态将保持不变
    - `update-namespace-roles`
        - 用于向地址分配角色和从地址撤销角色
        - 与命名空间更新一样，角色更新也是增量的
    - `claim-voucher`
        - 主要用于用户未被授权接收权限资产但从 Biya Chain 模块收到资金的情况。资金将保存在 Biya Chain 模块地址中，直到用户获得接收资产的正确权限

## `create-namespace`

```bash
biyachaind tx permissions create-namespace <namespace.json> [flags]
```

- JSON 文件应具有以下格式（提交前删除所有注释）：

```json
{ // 提交前删除所有注释！
  "denom": "factory/biya1address/myTokenDenom",
  "contract_hook": "ContractHookAddress",
  "role_permissions": [ // 警告：确保为所有命名空间管理角色设置角色权限！
    {
      "name": "EVERYONE",
      "role_id": 0,
      "permissions": 10 // SEND (8) + RECEIVE (2)；排除 MINT、SUPER_BURN 和管理操作
    },
    {
      "name": "admin",
      "role_id": 1,
      "permissions": 2013265920 // MODIFY_ROLE_PERMISSIONS、MODIFY_ROLE_MANAGERS 等（所有命名空间管理操作）
    },
    {
      "name": "user",
      "role_id": 2,
      "permissions": 15 // MINT (1)、RECEIVE (2)、BURN (4)、SEND (8)
    }
  ],
  "actor_roles": [
    {
      "actor": "biya1specificactoraddress",
      "roles": ["admin"]
    },
    {
      "actor": "biya1anotheractoraddress",
      "roles": ["user"]
    }
  ],
  "role_managers": [ // 警告：确保为所有命名空间管理角色设置角色管理器！
    {
      "manager": "biya1manageraddress",
      "roles": ["admin"]
    }
  ],
  "policy_statuses": [ 
    {
      "action": 1, // Action_MINT
      "is_disabled": false,
      "is_sealed": false
    },
    {
      "action": 4, // Action_BURN
      "is_disabled": false,
      "is_sealed": false
    }
  ],
  "policy_manager_capabilities": [
    {
      "manager": "biya1policymanageraddress",
      "action": 268435456, // MODIFY_CONTRACT_HOOK
      "can_disable": true,
      "can_seal": false
    }
  ]
}

```

## `update-namespace`

```json
biyachaind tx permissions update-namespace <namespace-update.json> [flags]
```

- 命名空间更新是增量的，因此除非在 JSON 中明确说明更改，否则现有状态将保持不变

```json
{ // 提交前删除所有注释！
  "denom": "factory/biya1address/myTokenDenom",
  "contract_hook": {
    "new_value": "newContractHookAddress"
  },
  "role_permissions": [
    {
      "name": "user",
      "role_id": 2,
      "permissions": 10 // RECEIVE (2) + SEND (8)
    },
    {
      "name": "EVERYONE",
      "role_id": 0,
      "permissions": 0 // 撤销所有权限
    }
  ],
  "role_managers": [
    {
      "manager": "biya1manageraddress",
      "roles": ["admin", "user"]
    }
  ],
  "policy_statuses": [
    {
      "action": 1, // MINT
      "is_disabled": true,
      "is_sealed": false
    },
    {
      "action": 4, // BURN
      "is_disabled": false,
      "is_sealed": true
    }
  ],
  "policy_manager_capabilities": [
    {
      "manager": "biya1policymanageraddress",
      "action": 536870912, // MODIFY_ROLE_PERMISSIONS
      "can_disable": true,
      "can_seal": false
    }
  ]
}

```

## `update-namespace-roles`

```json
biyachaind tx permissions update-namespace-roles <roles.json> [flags]
```

```json
{
  "denom": "factory/biya1address/myTokenDenom",
  "role_actors_to_add": [
    {
      "role": "admin",
      "actors": [
        "biya1actoraddress1",
        "biya1actoraddress2"
      ]
    },
    {
      "role": "user",
      "actors": [
        "biya1actoraddress3"
      ]
    }
  ],
  "role_actors_to_revoke": [
    {
      "role": "user",
      "actors": [
        "biya1actoraddress4"
      ]
    },
    {
      "role": "admin",
      "actors": [
        "biya1actoraddress5"
      ]
    }
  ]
}
```

## `claim-voucher`

```bash
biyachaind tx permissions claim-voucher <denom>
```

- 此命令不需要 JSON，因为唯一需要的参数是代币单位
