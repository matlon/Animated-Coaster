using UnityEngine;
using System.Collections;

public class SetForceTrigger : MonoBehaviour {

    private GoForward forwardScript;
    public float force;
    public float targetSpeed;
    public bool hasTargetSpeed;

    void OnTriggerEnter(Collider other)
    {
        forwardScript = other.transform.parent.GetComponent<GoForward>();
        forwardScript.force = force;
        forwardScript.targetSpeed = targetSpeed;
        forwardScript.hasTargetSpeed = hasTargetSpeed;
    }
}
