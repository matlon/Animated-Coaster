using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IgnoreCollider : MonoBehaviour {
    public Collider otherCollider;
    void Start()
    {
        Physics.IgnoreCollision(GetComponent<Collider>(), otherCollider);
    }
}