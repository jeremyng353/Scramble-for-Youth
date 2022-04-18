class Unit {
    constructor(player, id, maxHp, atkDmg, atkRange, moveRange) {
        this.player = player;
        this.id = id;
        this.maxHp = maxHp;
        this.hp = maxHp;
        this.atkDmg = atkDmg;
        this.atkRange = atkRange;
        this.moveRange = moveRange;
        this.alive = true;
        this.respawnTimer = 0;
        this.moved = false;
    }
}

export {Unit};